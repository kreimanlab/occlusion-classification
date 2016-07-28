classdef LibsvmClassifierCCV < Classifier
    %LIBSVMCLASSIFIER Libsvm One-vs-all SVM Classifier with
    %cross-validation across C.
    
    properties
        name = 'libsvmccv'
        classifier
        t
        cValues = [1e-4, 1e-3, 1e-2, 1e-1, 1, 1e1, 1e2, 1e3, 1e4]
    end
    
    methods
        function obj = LibsvmClassifierCCV(featureExtractor, t)
            obj@Classifier(featureExtractor);
            if ~exist('t', 'var')
                t = 0;
            end
            obj.t = t;
        end
        
        function fit(self, X, Y)
            bestC = Inf;
            bestPerformance = 0;
            for cValue = self.cValues
                fun = curry(@self.trainAndTest, cValue);
                performance = crossval(fun, X, Y, 'kfold', 5);
                performance = mean(performance);
                if performance > bestPerformance
                    bestC = cValue;
                    bestPerformance = performance;
                end
            end
            self.classifier = LibsvmClassifier([], self.t, bestC);
            self.classifier.fit(X, Y);
        end
        
        function performance = trainAndTest(self, c, ...
                Xtrain, Ytrain, Xtest, Ytest)
            cls = LibsvmClassifier([], self.t, c);
            cls.fit(Xtrain, Ytrain);
            pred = cls.classify(Xtest);
            performance = mean(pred == Ytest);
        end
        
        function Y = classify(self, X)
            Y = self.classifier.classify(X);
        end
    end
end
