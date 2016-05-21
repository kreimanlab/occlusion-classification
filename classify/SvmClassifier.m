classdef SvmClassifier < Classifier
    %SVMCLASSIFIER One-vs-all SVM Classifier.
    
    properties
        classifier
    end
    
    methods
        function obj = SvmClassifier(featureExtractor)
            obj@Classifier(featureExtractor);
        end
        
        function fit(self, features, labels)
            self.classifier = fitcecoc(features,labels);
        end
        
        function labels = classify(self, features)
            labels = self.classifier.predict(features);
        end
    end    
end
