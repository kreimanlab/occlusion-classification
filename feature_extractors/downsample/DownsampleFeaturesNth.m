classdef DownsampleFeaturesNth < FeatureExtractor
    % Downsample features to a given length using only every n-th feature
    % according to the length
    
    properties
        downsampledLength
        featuresInput
    end
    
    methods
        function obj = DownsampleFeaturesNth(downsampledLength, featuresInput)
            obj.downsampledLength = downsampledLength;
            obj.featuresInput = featuresInput;
        end
        
        function name = getName(self)
            name = [self.featuresInput.getName() ...
                '-downsample' num2str(self.downsampledLength) '_nth'];
        end
        
        function features = extractFeatures(self, images, runType)
            features = self.featuresInput.extractFeatures(images, runType);
            features = downsampleNth(features, self.downsampledLength);
        end
    end
end
