import os
import random
from string import digits

import cv2
import numpy as np

from pixel.gaussian_naive_bayes import PixelMLESklearnClassifier

labels = dict(animal=1, chair=2)


def load_images(directory):
    """
    :return: an array consisting of dicts (data, label, name)
    """
    files = [f for f in os.listdir(directory)
             if os.path.isfile(os.path.join(directory, f))]
    return [dict(name=f,
                 data=np.array(cv2.imread(os.path.join(directory, f), 0)),
                 label=labels[os.path.splitext(f)[0].translate(None, digits)])
            for f in files]


def split_data(data):
    n_data = len(data)
    random.seed(0)  # reproducible pseudo-randomness
    random.shuffle(data)  # shuffle instead of sample for disjoint sets
    n_train_data = int(0.7 * n_data)
    n_validation_data = int(0.2 * n_data)
    n_test_data = int(0.1 * n_data)
    train_data = data[:n_train_data]
    validation_data = data[n_train_data:n_train_data + n_validation_data]
    test_data = data[n_train_data + n_validation_data:n_train_data + n_validation_data + n_test_data]
    return train_data, validation_data, test_data


def get_shape(images):
    height, width = images[0]['data'].shape[:2]
    for img in images:
        h, w = img['data'].shape[:2]
        if (h, w) != (height, width):
            raise ValueError("Shape " + str(h) + "," + str(w) + " of " + img['name'] +
                             " is not equal to default shape " + str(h) + "," + str(w))
    return [height, width]


if __name__ == '__main__':
    data = load_images(os.path.join(os.path.dirname(__file__), 'data/non-occluded'))
    shape = get_shape(data)
    train_data, validation_data, test_data = split_data(data)

    classifier = PixelMLESklearnClassifier()
    classifier.train(train_data, validation_data)

    test_data = train_data + validation_data + test_data
    prediction = classifier.test(test_data)
    real_labels = np.asarray([d['label'] for d in test_data])
    n_correct_labels = (prediction == real_labels).sum()
    print "Pred", prediction
    print "Real", real_labels
    print "Correctly classified %d out of %d images (%.2f%%)" \
          % (n_correct_labels, real_labels.shape[0], 100. * n_correct_labels / real_labels.shape[0])
