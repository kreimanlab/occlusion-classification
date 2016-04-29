from sklearn.cross_validation import ShuffleSplit
from sklearn.grid_search import GridSearchCV
from sklearn.naive_bayes import GaussianNB
import numpy as np

from classifier import Classifier


class PixelGNBCVClassifier(Classifier):
    """
    Conceptual example, does not run
    """
    def __init__(self):
        super(PixelGNBCVClassifier, self).__init__()
        self.gnb = GaussianNB()

    def train(self, training_data, validation_data):
        cv = ShuffleSplit(len(training_data))
        cv_search = GridSearchCV(estimator=self.gnb, cv=cv, param_grid=self.build_param_grid(training_data))
        # does not work because gnb does not allow theta_ and sigma_ to be modified
        cv_search.fit([self.flatten_matrix(t['data']) for t in training_data + validation_data],
                      [t['label'] for t in training_data + validation_data])
        self.gnb = GaussianNB(theta_=cv_search.best_estimator_.theta_, sigma_=cv_search.best_estimator_.sigma_)

    @staticmethod
    def build_param_grid(data):
        num = 20
        collapsed_values = [value for data_row in data for matrix_row in data_row['data'] for value in matrix_row]
        data_shape = (data[0]['data']).shape
        return dict(theta_=np.linspace(min(collapsed_values), max(collapsed_values), num=num),
                    sigma_=np.linspace(0, data_shape[0] * data_shape[1], num=num))

    def test(self, test_data):
        return self.gnb.predict([self.flatten_matrix(t['data']) for t in test_data])
