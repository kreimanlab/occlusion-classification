from sklearn.decomposition import PCA
from sklearn.naive_bayes import GaussianNB
from sklearn.pipeline import make_pipeline

from classifier import Classifier


class PixelPCAGNBClassifier(Classifier):
    def __init__(self):
        super(PixelPCAGNBClassifier, self).__init__()
        self.classifier = make_pipeline(PCA(), GaussianNB())

    def train(self, training_data, validation_data):
        self.classifier.fit([self.flatten_matrix(t['data']) for t in training_data],
                            [t['label'] for t in training_data])

    def test(self, test_data):
        return self.classifier.predict([self.flatten_matrix(t['data']) for t in test_data])
