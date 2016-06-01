classdef FeatureExtractor < handle
    %FEATUREEXTRACTOR Extract features of a given data row
    
    methods (Abstract)
        getName(self)
        extractFeatures(self, rows, runType, labels)
    end
end
