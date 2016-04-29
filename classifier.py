from abc import ABCMeta, abstractmethod

import numpy
import theano


class Classifier:
    def __init__(self):
        pass

    __metaclass__ = ABCMeta

    @abstractmethod
    def train(self, training_data, validation_data):
        raise NotImplementedError

    @abstractmethod
    def test(self, test_data):
        raise NotImplementedError

    @staticmethod
    def get_data(data):
        return theano.shared(numpy.asarray([d['data'] for d in data], dtype=theano.config.floatX), borrow=True)

    @staticmethod
    def get_labels(data):
        return theano.shared(numpy.asarray([d['label'] for d in data], dtype=theano.config.floatX), borrow=True)

    @staticmethod
    def flatten_matrix(matrix):
        """
        takes in an (m, n) numpy array and flattens it
        into an array of shape (1, m * n)
        """
        s = matrix.shape[0] * matrix.shape[1]
        matrix_wide = matrix.reshape(1, s)
        return matrix_wide[0]
