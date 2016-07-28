classdef BipolarTrainFeatures < BipolarFeatures
    % Squashes the training features to {-1, +1} based on a given threshold.
    
    methods
        function obj = BipolarTrainFeatures(threshold, featuresInput)
            obj@BipolarFeatures(threshold, featuresInput);
        end
        
        function name = getName(self)
            name = [getName@BipolarFeatures(self) '_train'];
        end
        
        function features = extractFeatures(self, images, runType, labels)
            if runType == RunType.Train
                features = extractFeatures@BipolarFeatures(self, ...
                    images, runType, labels);
            else
                features = self.featuresInput.extractFeatures(...
                    images, runType, labels);
            end
        end
    end
end

