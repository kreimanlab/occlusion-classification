import os
import random

import numpy as np
from keras.layers import SimpleRNN
from keras.models import Sequential


def create_model():
    model = Sequential()
    model.add(SimpleRNN(output_dim=feature_size, input_shape=(None, feature_size),
                        activation='relu',
                        # fixed_W=True,
                        return_sequences=False, name='RNN'))
    model.compile(loss="mse", optimizer="rmsprop", metrics=["accuracy"])
    return model


def train(model, X, Y, num_epochs=10, batch_size=512, validation_split=0.1):
    assert len(X) == len(Y)
    model.fit(reshape_x(X), Y,
              batch_size=batch_size, nb_epoch=num_epochs, validation_split=validation_split,
              verbose=1)
    model.save_weights('model_weights.hdf5', overwrite=True)
    return model


def reshape_x(x):
    return np.resize(x, [x.shape[0], 1, x.shape[1]])


def run(model, X, num_timesteps=6):
    Y = {}
    for t in range(0, num_timesteps):
        if t == 0:
            Y[t] = X
        else:
            Y[t] = model.predict(reshape_x(X))
    return Y


def load_occluded_features():
    features = np.zeros((13000, feature_size))
    for i in range(1, 13000, 1000):
        filename = os.path.join(os.path.dirname(os.path.realpath(__file__)),
                                "../../data/features/data_occlusion_klab325v2/",
                                "caffenet_fc7_ims_%d-%d.txt" % (i, i + 999))
        _features = np.loadtxt(filename, usecols=range(1, feature_size + 1))
        features[i - 1:i - 1 + 1000, :] = _features
    return features


def load_whole_features():
    filename = os.path.join(os.path.dirname(os.path.realpath(__file__)),
                            "../../data/features/klab325_orig/",
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


if __name__ == '__main__':
    random.seed(0)
    feature_size = 4096
    model = create_model()
    # data
    Y = load_whole_features()
    X = load_occluded_features()
    Y = align_features(Y, X)
    # TODO: cross validation across objects/categories
    model = train(model, X, Y, num_epochs=1000)
    predicted_Y = run(model, X)
    np.savetxt('predicted_Y.txt', predicted_Y)
