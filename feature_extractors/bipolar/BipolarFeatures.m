classdef BipolarFeatures < FeatureExtractor
    % Squashes the features to {-1, +1} based on a given threshold.
    
    properties
        featuresInput
        threshold
    end
    
    methods
        function obj = BipolarFeatures(threshold, featuresInput)
            obj.threshold = threshold;
            obj.featuresInput = featuresInput;
        end
        
        function name = getName(self)
            name = [self.featuresInput.getName() ...
                '-bipolar' num2str(self.threshold)];
        end
        
        function features = extractFeatures(self, images, runType)
            T = self.featuresInput.extractFeatures(images, runType);
            features = bipolarize(T, self.threshold);
        end
    end
end

