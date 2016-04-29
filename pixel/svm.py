from sklearn.naive_bayes import GaussianNB
from sklearn.svm import SVC

from classifier import Classifier


class PixelSVMClassifier(Classifier):
    def __init__(self):
        super(PixelSVMClassifier, self).__init__()
        self.classifier = SVC()

    def train(self, training_data, validation_data):
        self.classifier.fit([self.flatten_matrix(t['data']) for t in training_data],
                            [t['label'] for t in training_data])

    def test(self, test_data):
        return self.classifier.predict([self.flatten_matrix(t['data']) for t in test_data])
