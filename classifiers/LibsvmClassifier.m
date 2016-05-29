classdef LibsvmClassifier < Classifier
    %LIBSVMCLASSIFIER Libsvm One-vs-all SVM Classifier.
    
    properties
        model
        c
    end
    
    methods
        function obj = LibsvmClassifier(featureExtractor, c)
            obj@Classifier(featureExtractor);
            if ~exist('c', 'var')
                c = 1;
            end
            obj.c = c;
        end
        
        function fit(self, X, Y)
            self.model = libsvmtrain(Y, X, ['-q -c ' num2str(self.c)]);
        end
        
        function Y = classify(self, X)
            Y = libsvmpredict(zeros(size(X, 1), 1), ...
                X, self.model, '-q');
        end
    end
end
