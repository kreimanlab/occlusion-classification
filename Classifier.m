classdef Classifier < handle
    %Interface for classifiers
    
    properties
        classifier
    end
    
    methods
        function fit(self, features, labels)
            self.classifier = fitcecoc(features,labels);
        end
        
        function labels = predict(self, rows)
            labels = self.classifier.predict(rows);
        end
    end
    
    methods (Abstract)
        getName(self)
        extractFeatures(self, images, runType)
    end
end

