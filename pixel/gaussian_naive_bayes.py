from sklearn.naive_bayes import GaussianNB

from classifier import Classifier


class PixelGNBClassifier(Classifier):
    def __init__(self):
        super(PixelGNBClassifier, self).__init__()
        self.gnb = GaussianNB()

    def train(self, training_data, validation_data):
        self.gnb.fit([self.flatten_matrix(t['data']) for t in training_data],
                     [t['label'] for t in training_data])

    def test(self, test_data):
        return self.gnb.predict([self.flatten_matrix(t['data']) for t in test_data])
