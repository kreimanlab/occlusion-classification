classdef DownsampleFeaturesVar < FeatureExtractor
    % Downsample features to a given length using the features with the
    % highest variance in the training phase
    
    properties
        downsampledLength
        featuresInput
        selectedFeatureIndices
    end
    
    methods
        function obj = DownsampleFeaturesVar(downsampledLength, featuresInput)
            obj.downsampledLength = downsampledLength;
            obj.featuresInput = featuresInput;
        end
        
        function name = getName(self)
            name = [self.featuresInput.getName() ...
                '-downsample' num2str(self.downsampledLength) '_var'];
        end
        
        function features = extractFeatures(self, images, runType, ~)
            features = self.featuresInput.extractFeatures(images, runType);
            if runType == RunType.Train
                variances = var(features, 1);
                [~, sortedIndices] = sort(variances, 'descend');
                self.selectedFeatureIndices = ...
                    sortedIndices(1:self.downsampledLength);
            end
            features = ...
                features(:, self.selectedFeatureIndices);
        end
    end
end
