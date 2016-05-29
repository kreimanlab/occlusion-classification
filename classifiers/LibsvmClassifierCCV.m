classdef LibsvmClassifierCCV < Classifier
    %LIBSVMCLASSIFIER Libsvm One-vs-all SVM Classifier with
    %cross-validation across C.
    
    properties
        classifier
        cValues = [1e-4, 1e-3, 1e-2, 1e-1, 1, 1e1, 1e2, 1e3, 1e4]
    end
    
    methods
        function obj = LibsvmClassifierCCV(featureExtractor)
            obj@Classifier(featureExtractor);
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
            self.classifier = LibsvmClassifier([], bestC);
            self.classifier.fit(X, Y);
        end
        
        function performance = trainAndTest(~, c, ...
                Xtrain, Ytrain, Xtest, Ytest)
            cls = LibsvmClassifier([], c);
            cls.fit(Xtrain, Ytrain);
            pred = cls.classify(Xtest);
            performance = mean(pred == Ytest);
        end
        
        function Y = classify(self, X)
            Y = self.classifier.classify(X);
        end
    end
end
