classdef FeatureExtractor
    %FEATUREEXTRACTOR Extract features of a given data row
    
    methods (Abstract)
        extractFeatures(self, rows)
    end
end
