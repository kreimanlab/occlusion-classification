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
        numTrainedFeatures
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
            self.numTrainedFeatures = size(X, 2);
        end
        
        function Y = classify(self, X)
            if size(X, 2) ~= self.numTrainedFeatures
%                 error(['invalid number of features: ' ...
%                     'expected ' num2str(self.numTrainedFeatures) ...
%                     ', got ' num2str(size(X, 2)) ]);
            end
            Y = libsvmpredict(rand(size(X, 1), 1), ...
                X, self.model, '-q');
        end
    end
end
