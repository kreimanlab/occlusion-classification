classdef FeatureExtractor < handle
    %FEATUREEXTRACTOR Extract features of a given data row
    
    methods (Abstract)
        extractFeatures(self, rows, runType)
    end
end
