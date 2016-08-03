import argparse
import os
import random

import functools
import numpy as np
import scipy.io
from keras.layers import SimpleRNN
from keras.models import Sequential
from sklearn.cross_validation import KFold, train_test_split


class RowProvider:
    def get_kfolds(self):
        """
        :return: triple train_kfolds, validation_kfolds, test_kfolds
        """
        pass

    def get_data_indices_from_kfolds(self, kfold_values):
        pass


class RowsAcrossImages(RowProvider):
    def __init__(self, num_occluded_features):
        self.num_occluded_features = num_occluded_features

    def get_kfolds(self, num_kfolds=5, validation_split=0.1):
        for train_val, test in KFold(self.num_occluded_features, num_kfolds):
            train, val = train_test_split(train_val, test_size=validation_split)
            yield train, val, test

    def get_data_indices_from_kfolds(self, rows):
        return rows


class RowsAcrossObjects(RowProvider):
    def __init__(self, num_occluded_features, pres):
        self.num_occluded_features = num_occluded_features

        assert len(pres) == num_occluded_features, \
            "len(pres) = %d and num_occluded_features = %d do not match" % (len(pres), num_occluded_features)
        self.pres = pres

    def get_kfolds(self, num_kfolds=5, validation_split=0.1):
        unique_pres = list(set(self.pres))
        kfold = KFold(len(unique_pres), num_kfolds)
        for train_val_object_indices, predict_object_indices in kfold:
            train_object_indices, val_object_indices = train_test_split(train_val_object_indices,
                                                                        test_size=validation_split)

            train_objects = self.get_objects(train_object_indices)
            val_objects = self.get_objects(val_object_indices)
            predict_objects = self.get_objects(predict_object_indices)
            yield (train_objects, val_objects, predict_objects)

    def get_data_indices_from_kfolds(self, objects):
        return [i for i in range(len(self.pres)) if self.pres[i] in objects and i < self.num_occluded_features]

    def get_objects(self, pres_indices):
        return [self.pres[i] for i in pres_indices]


class RowsAcrossCategories(RowProvider):
    def __init__(self, num_occluded_features):
        self.num_occluded_features = num_occluded_features

        self.categories = np.loadtxt(os.path.join(os.path.dirname(os.path.realpath(__file__)),
                                                  "../../../data/data_occlusion_klab325v2-categories.txt"), dtype='int')
        assert len(self.categories) == num_occluded_features, \
            "len(categories) = %d and num_occluded_features = %d do not match" \
            % (len(self.categories), num_occluded_features)

    def get_kfolds(self, num_kfolds=5, validation_split=0.1):
        unique_categories = list(set(self.categories))
        assert num_kfolds == len(unique_categories), \
            "num_kfolds = %d and len(unique_categories) = %d do not match" % (num_kfolds, len(unique_categories))
        kfold = KFold(len(unique_categories), num_kfolds)
        for train_val_category_indices, predict_category_indices in kfold:
            train_category_indices, val_category_indices = train_test_split(train_val_category_indices,
                                                                            test_size=validation_split)
            train_categories = [unique_categories[i] for i in train_category_indices]
            val_categories = [unique_categories[i] for i in val_category_indices]
            predict_categories = [unique_categories[i] for i in predict_category_indices]
            yield (train_categories, val_categories, predict_categories)

    def get_data_indices_from_kfolds(self, categories):
        return [i for i in range(len(self.categories))
                if self.categories[i] in categories and i < self.num_occluded_features]


class RowsWithWhole(RowProvider):
    def __init__(self, inner_provider, pres):
        self.inner_provider = inner_provider
        self.pres = pres

    def get_kfolds(self):
        return self.inner_provider.get_kfolds

    def get_data_indices_from_kfolds(self, kfold_values):
        indices = self.inner_provider.get_data_indices_from_kfolds(kfold_values)
        pres = list(set(self.pres[indices]))
        return np.concatenate(([i + 325 for i in indices], pres))


def create_model(feature_size):
    model = Sequential()
    model.add(SimpleRNN(output_dim=feature_size, input_shape=(None, feature_size),
                        activation='relu',
                        return_sequences=True, name='RNN'))
    model.compile(loss="mse", optimizer="rmsprop", metrics=["accuracy"])
    return model


def train(model, X_train, Y_train, X_val, Y_val, num_epochs=10, batch_size=512):
    assert len(X_train) == len(Y_train), \
        "len(X_train) = %d and len(Y_train) = %d do not match" % (len(X_train), len(Y_train))
    assert len(X_val) == len(Y_val), \
        "len(X_val) = %d and len(Y_val) = %d do not match" % (len(X_val), len(Y_val))
    initial_weights = model.get_weights()
    validation_losses = []
    for epoch in range(num_epochs):
        print('Epoch %d' % epoch)
        model.fit(reshape_features(X_train), reshape_features(Y_train),
                  batch_size=batch_size, nb_epoch=1, verbose=0)
        val_metrics = model.evaluate(reshape_features(X_val), reshape_features(Y_val), batch_size=batch_size, verbose=0)
        validation_losses.append(val_metrics[0])
    best_epoch = np.array(validation_losses).argmin()
    print('retraining on whole data up to best validation epoch %d' % best_epoch)
    model.reset_states()
    model.set_weights(initial_weights)
    model.fit(reshape_features(X_train), reshape_features(Y_train),
              batch_size=batch_size, nb_epoch=best_epoch, verbose=1)


def reshape_features(features, timesteps=1):
    features = np.resize(features, [features.shape[0], 1, features.shape[1]])
    return np.repeat(features, timesteps, 1)


def reshape_features_and_add_mask(features, mask_features, timesteps=2, mask_timestep_onset=1):
    features = reshape_features(features, mask_timestep_onset)
    mask_features = reshape_features(mask_features, timesteps - mask_timestep_onset)
    return np.concatenate((features, mask_features), axis=1)


def predict(model, X, feature_reshaper, timesteps=6):
    Y = {}
    Y[0] = X
    predictions = model.predict(feature_reshaper(X, timesteps))
    for t in range(1, timesteps + 1):
        Y[t] = predictions[:, t - 1, :]
    return Y


def load_occluded_features(features_directory, feature_size):
    filename = os.path.join(features_directory, 'RNN_features_fc7_noRelu_t0.mat')
    data = scipy.io.loadmat(filename)
    features = data['features']
    features = features[325:, :]
    assert features.shape == (13000, feature_size)
    return features


def load_whole_features(features_directory, feature_size):
    filename = os.path.join(features_directory, "klab325_orig",
                            "caffenet_fc7_ims_1-325.txt")
    features = np.loadtxt(filename, usecols=range(1, feature_size + 1))
    return features


def load_mask_features(features_directory, feature_size):
    raise NotImplementedError()


def align_features(whole_features, occluded_features, pres):
    assert len(pres) == len(occluded_features), \
        "len(pres) = %d and len(occluded_features) = %d do not match" % (len(pres), len(occluded_features))
    aligned_whole = np.zeros(occluded_features.shape)
    for i in range(len(occluded_features)):
        corresponding_whole = int(pres[i])
        aligned_whole[i, :] = whole_features[corresponding_whole - 1, :]
    return aligned_whole


def get_features_directory(use_central=True):
    central_dir = "/groups/kreiman/martin/features"
    if use_central and os.path.isdir(central_dir):
        return central_dir
    features_dir = os.path.join(os.path.dirname(os.path.realpath(__file__)), "../../../data/features")
    if not os.path.isdir(features_dir):
        os.mkdir(features_dir)
    return features_dir


def get_weights_file(kfold):
    weights_dir = os.path.join(os.path.dirname(os.path.realpath(__file__)), '..', '..', '..', 'data', 'weights')
    if not os.path.isdir(weights_dir):
        os.mkdir(weights_dir)
    weights_filename = 'model_weights-kfold%d.hdf5' % kfold
    weights_file = os.path.join(weights_dir, weights_filename)
    return weights_file


def cross_validate_prediction(model, X, Y, row_provider, feature_reshaper, train_epochs, max_timestep):
    """
    for each kfold, train on subset of features and predict the rest.
    Ultimately predict all features by concatenating them for each kfold.
    """
    initial_model_weights = model.get_weights()
    predicted_features = np.zeros((max_timestep + 1,) + X.shape)
    num_kfold = 0
    for train_kfolds, val_kfolds, predict_kfolds in row_provider.get_kfolds():
        model.reset_states()
        model.set_weights(initial_model_weights)

        train_indices = row_provider.get_data_indices_from_kfolds(train_kfolds)
        validation_indices = row_provider.get_data_indices_from_kfolds(val_kfolds)
        predict_indices = row_provider.get_data_indices_from_kfolds(predict_kfolds)
        X_train, Y_train = X[train_indices], Y[train_indices]
        X_val, Y_val = X[validation_indices], Y[validation_indices]
        X_predict = X[predict_indices]
        weights_file = get_weights_file(num_kfold)
        if os.path.isfile(weights_file):
            print('[kfold %d] using pre-trained weights %s' % (num_kfold, weights_file))
            model.load_weights(weights_file)
        else:
            print('[kfold %d] training...' % num_kfold)
            train(model, X_train, Y_train, X_val, Y_val, num_epochs=train_epochs)
            model.save_weights(weights_file, overwrite=True)
        print('[kfold %d] predicting...' % num_kfold)
        predicted_Y = predict(model, X_predict, feature_reshaper, timesteps=max_timestep)
        for timestep, prediction in predicted_Y.items():
            predicted_features[timestep, predict_indices, :] = prediction

        num_kfold += 1
    return predicted_features


def run_rnn():
    # params - fixed
    features_directory = get_features_directory()
    feature_size = 4096
    num_epochs = 100
    max_timestep = 6
    num_occluded_features = 13000
    pres = np.loadtxt(os.path.join(os.path.dirname(os.path.realpath(__file__)),
                                   "../../../data/data_occlusion_klab325v2-pres.txt"), dtype='int')
    row_providers = {'rows': RowsAcrossImages(num_occluded_features),
                     'objects': RowsAcrossObjects(num_occluded_features, pres),
                     'categories': RowsAcrossCategories(num_occluded_features)}
    # params - command line
    parser = argparse.ArgumentParser(description='Train and predict whole features from occluded ones')
    parser.add_argument('--num_epochs', type=int, default=100,
                        help='how many epochs to search for optimal weights')
    parser.add_argument('--cross_validation', type=str, default='categories',
                        choices=row_providers.keys(), help='across what to validate')
    parser.add_argument('--add_whole_indices', action='store_true', default=False)
    parser.add_argument('--mask_onset', type=int, default=-1, choices=range(1, 6),
                        help='across what to validate')
    args = parser.parse_args()
    row_provider = row_providers[args.cross_validation]
    if args.add_whole_indices:
        row_provider = RowsWithWhole(row_provider, pres)
    if args.mask_onset >= 0:
        mask_features = load_mask_features(features_directory, feature_size)
        feature_reshaper = functools.partial(reshape_features_and_add_mask,
                                             mask_features=mask_features, mask_onset=args.mask_onset)
    else:
        feature_reshaper = reshape_features

    # model
    model = create_model(feature_size)
    # load data
    whole_features = load_whole_features(features_directory, feature_size)
    occluded_features = load_occluded_features(features_directory, feature_size)
    aligned_whole_features = align_features(whole_features, occluded_features, pres)
    # run
    X = np.concatenate((whole_features, occluded_features))
    Y = aligned_whole_features
    predicted_features = cross_validate_prediction(model, X, Y, row_provider, feature_reshaper,
                                                   train_epochs=num_epochs, max_timestep=max_timestep)
    # save
    print('saving...')
    for timestep in range(0, max_timestep + 1):
        features = predicted_features[timestep]
        # save
        filename = 'RnnFeatures-timestep%d' % timestep
        filepath = os.path.join(get_features_directory(False), filename)
        scipy.io.savemat(filepath, {'features': features})


if __name__ == '__main__':
    random.seed(0)
    run_rnn()
