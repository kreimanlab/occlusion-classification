classdef AlexnetFc7Classifier < AlexnetClassifier
    % Classifier based on Alexnet feature-extraction.
    % Uses a linear classifier on top of the Alexnet fc7 output.
    
    methods
        function obj = AlexnetFc7Classifier()
            fc7OutputLength = 4096;
            obj = obj@AlexnetClassifier(fc7OutputLength);
        end
        
        function name = getName(~)
            name = 'alexnet-fc7';
        end
        
        function features = getImageFeatures(self, image)
            features = getFc7Output(self.netParams, image);
        end
    end
end
