classdef LibsvmClassifier < Classifier
    %LIBSVMCLASSIFIER Libsvm One-vs-all SVM Classifier.
    
    properties (Constant)
        kernelNames = containers.Map([0, 1, 2, 3], ...
            {'linear', 'polynomial', 'radial', 'sigmoid'});
    end
    
    properties
        name
        model
        t % kernel type
        c % cost of C-SVC
    end
    
    methods
        function obj = LibsvmClassifier(featureExtractor, t, c)
            obj@Classifier(featureExtractor);
            if ~exist('t', 'var')
                t = 0;
            end
            obj.t = t;
            if ~exist('c', 'var')
                c = 1;
            end
            obj.c = c;
            obj.name = ['libsvm_' obj.kernelNames(obj.t)];
        end
        
        function fit(self, X, Y)
            self.model = libsvmtrain(Y, X, ...
                ['-q -t ' num2str(self.t) ' -c ' num2str(self.c)]);
        end
        
        function Y = classify(self, X)
            Y = libsvmpredict(zeros(size(X, 1), 1), ...
                X, self.model, '-q');
        end
    end
end
