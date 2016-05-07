classdef Classifier < handle
    %Interface for classifiers
    
    properties
    end
    
    methods (Abstract)
        getName(self)
        extractFeatures(self, images)
        fit(self, features, labels)
        predict(self, images)
    end
end

