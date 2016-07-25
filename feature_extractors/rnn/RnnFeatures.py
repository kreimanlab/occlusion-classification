import os
import random

import numpy as np
from keras.layers import SimpleRNN
from keras.models import Sequential
from sklearn.cross_validation import KFold


def create_model(feature_size):
    model = Sequential()
    model.add(SimpleRNN(output_dim=feature_size, input_shape=(None, feature_size),
                        activation='relu',
                        return_sequences=True, name='RNN'))
    model.compile(loss="mse", optimizer="rmsprop", metrics=["accuracy"])
    return model


def train(model, X, Y, num_epochs=10, batch_size=512, validation_split=0.1):
    assert len(X) == len(Y)
    initial_weights = model.get_weights()
    validation_losses = []
    for epoch in range(num_epochs):
        print('Epoch %d' % epoch)
        metrics = model.fit(reshape_features(X), reshape_features(Y),
                            batch_size=batch_size, nb_epoch=1, validation_split=validation_split, verbose=0)
        validation_losses.append(metrics.history['val_loss'][0])
    best_epoch = np.array(validation_losses).argmin()
    print('retraining on whole data up to best validation epoch %d' % best_epoch)
    model.reset_states()
    model.set_weights(initial_weights)
    model.fit(reshape_features(X), reshape_features(Y),
              batch_size=batch_size, nb_epoch=best_epoch, verbose=1)


def reshape_features(features, timesteps=1):
    features = np.resize(features, [features.shape[0], 1, features.shape[1]])
    return np.repeat(features, timesteps, 1)


def run(model, X, timesteps=6):
    Y = {}
    Y[0] = X
    predictions = model.predict(reshape_features(X, timesteps))
    for t in range(1, timesteps + 1):
        Y[t] = predictions[:, t - 1, :]
    return Y


def load_occluded_features(features_directory, feature_size):
    num_features = 13325
    features = np.zeros((num_features, feature_size))
    for i in range(1, num_features, 1000):
        filename = os.path.join(features_directory, "data_occlusion_klab325v2",
                                "caffenet_fc7_ims_%d-%d.txt" % (i, min(i + 999, num_features)))
        _features = np.loadtxt(filename, usecols=range(1, feature_size + 1))
        features[i - 1:i - 1 + 1000, :] = _features
    return features


def load_whole_features(features_directory, feature_size):
    filename = os.path.join(features_directory, "klab325_orig",
                            "caffenet_fc7_ims_1-325.txt")
    features = np.loadtxt(filename, usecols=range(1, feature_size + 1))
    return features


def align_features(whole_features, occluded_features):
    pres = np.loadtxt(os.path.join(os.path.dirname(os.path.realpath(__file__)),
                                   "../../data/data_occlusion_klab325v2-pres.txt"))
    assert len(pres) == len(occluded_features)
    aligned_whole = np.zeros(occluded_features.shape)
    for i in range(len(occluded_features)):
        corresponding_whole = int(pres[i])
        aligned_whole[i, :] = whole_features[corresponding_whole - 1, :]
    return aligned_whole


def get_features_directory(use_central=True):
    central_dir = "/groups/kreiman/martin/features"
    if use_central and os.path.isdir(central_dir):
        return central_dir
    features_dir = os.path.join(os.path.dirname(os.path.realpath(__file__)), "../../data/features")
    if not os.path.isdir(features_dir):
        os.mkdir(features_dir)
    return features_dir


def get_weights_file(kfold):
    weights_dir = os.path.join(os.path.dirname(os.path.realpath(__file__)), '..', '..', 'data', 'weights')
    if not os.path.isdir(weights_dir):
        os.mkdir(weights_dir)
    weights_filename = 'model_weights-kfold%d.hdf5' % kfold
    weights_file = os.path.join(weights_dir, weights_filename)
    return weights_file


def indices_across_objects(occluded_features, num_kfolds):
    return KFold(occluded_features.shape[0], num_kfolds)


def indices_across_categories(occluded_features, num_kfolds):
    categories = np.loadtxt(os.path.join(os.path.dirname(os.path.realpath(__file__)),
                                         "../../data/data_occlusion_klab325v2-categories.txt"))
    assert len(categories) == len(occluded_features)
    unique_categories = list(set(categories))
    assert num_kfolds == len(unique_categories)
    kfold = KFold(len(unique_categories), num_kfolds)
    for train_category_indices, predict_category_indices in kfold:
        train_categories = [unique_categories[i] for i in train_category_indices]
        predict_categories = [unique_categories[i] for i in predict_category_indices]
        train_indices = [i for i in range(len(categories))
                         if categories[i] in train_categories and i < len(occluded_features)]
        predict_indices = [i for i in range(len(categories))
                           if categories[i] in predict_categories and i < len(occluded_features)]
        assert all([categories[i] in train_categories for i in train_indices])
        assert all([categories[i] in predict_categories for i in predict_indices])
        yield (train_indices, predict_indices)


def cross_validate_prediction(model, X, Y, rows, train_epochs, max_timestep):
    """
    for each kfold, train on subset of features and predict the rest.
    Ultimately predict all features by concatenating them for each kfold.
    """
    initial_model_weights = model.get_weights()
    predicted_features = np.zeros((max_timestep + 1,) + X.shape)
    num_kfold = 0
    for train_indices, predict_indices in rows:
        model.reset_states()
        model.set_weights(initial_model_weights)

        X_train, Y_train = X[train_indices], Y[train_indices]
        X_predict, Y_predict = X[predict_indices], Y[predict_indices]
        weights_file = get_weights_file(num_kfold)
        if os.path.isfile(weights_file):
            print('[kfold %d] using pre-trained weights %s' % (num_kfold, weights_file))
            model.load_weights(weights_file)
        else:
            print('[kfold %d] training...' % num_kfold)
            train(model, X_train, Y_train, num_epochs=train_epochs)
            model.save_weights(weights_file, overwrite=True)
        print('[kfold %d] predicting...' % num_kfold)
        predicted_Y = run(model, X_predict, timesteps=max_timestep)
        for timestep, prediction in predicted_Y.items():
            predicted_features[timestep, predict_indices, :] = prediction

        num_kfold += 1
    return predicted_features


def run_rnn():
    # params
    feature_size = 4096
    num_kfolds = 5
    num_epochs = 50
    max_timestep = 6
    # init model
    model = create_model(feature_size)
    # load data
    features_directory = get_features_directory()
    whole_features = load_whole_features(features_directory, feature_size)
    occluded_features = load_occluded_features(features_directory, feature_size)
    aligned_whole_features = align_features(whole_features, occluded_features)
    # run
    # row_provider = indices_across_objects(occluded_features, num_kfolds)
    row_provider = indices_across_categories(occluded_features, num_kfolds)
    predicted_features = cross_validate_prediction(model, occluded_features, aligned_whole_features,
                                                   row_provider, train_epochs=num_epochs, max_timestep=max_timestep)
    # save
    print('saving...')
    for timestep in range(0, max_timestep + 1):
        features = predicted_features[timestep]
        filename = 'RnnFeatures-timestep%d.txt' % timestep
        filepath = os.path.join(get_features_directory(False), filename)
        np.savetxt(filepath, features)


if __name__ == '__main__':
    random.seed(0)
    run_rnn()
