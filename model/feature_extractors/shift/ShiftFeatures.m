classdef ShiftFeatures < FeatureExtractor
    % shift all features by a given value
    
    properties
        shift
        featuresInput
    end
    
    methods
        function obj = ShiftFeatures(shift, featuresInput)
            obj.shift = shift;
            obj.featuresInput = featuresInput;
        end
    
        function name = getName(self)
            name = [self.featuresInput.getName() ...
                '-shift' num2str(self.shift)];
        end
        
        function features = extractFeatures(self, rows, runType, labels)
            features = self.featuresInput.extractFeatures(rows, runType, labels);
            shiftMatrix = self.shift * ones(size(features));
            features = features + shiftMatrix;
        end
    end
end
