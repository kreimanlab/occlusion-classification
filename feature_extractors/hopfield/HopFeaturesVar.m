classdef HopFeaturesVar < HopFeatures
    % Downsample by picking the features with the highest variance.
    
    properties
        selectedFeatureIndices
    end
    
    methods
        function obj = HopFeaturesVar(downsampledLength, featuresInput)
            obj@HopFeatures(downsampledLength, featuresInput);
        end
        
        function name = getName(self)
            name = [getName@HopFeatures(self) '_var'];
        end
        
        function downsampledFeatures = downsample(self, features, runType)
            if runType == RunType.Train
                variances = var(features, 1);
                [~, sortedIndices] = sort(variances, 'descend');
                self.selectedFeatureIndices = ...
                    sortedIndices(1:self.downsampledLength);
            end
            downsampledFeatures = ...
                features(:, self.selectedFeatureIndices);
        end
    end
end
