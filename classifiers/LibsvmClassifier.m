classdef LibsvmClassifier < Classifier
    %LIBSVMCLASSIFIER Libsvm One-vs-all SVM Classifier.
    
    properties
        classifier
    end
    
    methods
        function obj = LibsvmClassifier(featureExtractor)
            obj@Classifier(featureExtractor);
        end
        
        function fit(self, X, Y)
            self.classifier = libsvmtrain(Y, X, '-q -c 5');
        end
        
        function Y = classify(self, X)
            Y = libsvmpredict(zeros(size(X, 1), 1), ...
                X, self.classifier, '-q');
        end
    end
end
