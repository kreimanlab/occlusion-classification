classdef HopFeaturesSimple < HopFeatures
    % Simple downsampling by only picking every n-th feature
    
    methods
        function obj = HopFeaturesSimple(downsampledLength, featuresInput)
            obj@HopFeatures(downsampledLength, featuresInput);
        end
        
        function name = getName(self)
            name = [getName@HopFeatures(self) '_simple'];
        end
        
        function downsampledFeatures = downsample(self, features, ~)
            sampleSteps = ceil(size(features, 2) / self.downsampledLength);
            downsampledFeatures = zeros(size(features, 1), ...
                ceil(size(features, 2) / sampleSteps));
            for i = 1:size(features, 1)
                downsampledFeatures(i, :) = downsample(features(i, :), ...
                    sampleSteps);
            end
        end
    end
end
