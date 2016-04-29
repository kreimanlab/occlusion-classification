from sklearn.naive_bayes import GaussianNB

from classifier import Classifier


class PixelMLESklearnClassifier(Classifier):
    def __init__(self):
        super(PixelMLESklearnClassifier, self).__init__()
        self.gnb = GaussianNB()

    def train(self, training_data, validation_data):
        self.gnb.fit([self.flatten_matrix(t['data']) for t in training_data],
                     [t['label'] for t in training_data])

    def test(self, test_data):
        return self.gnb.predict([self.flatten_matrix(t['data']) for t in test_data])

    @staticmethod
    def flatten_matrix(matrix):
        """
        takes in an (m, n) numpy array and flattens it
        into an array of shape (1, m * n)
        """
        s = matrix.shape[0] * matrix.shape[1]
        matrix_wide = matrix.reshape(1, s)
        return matrix_wide[0]
