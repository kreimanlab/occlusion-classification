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
