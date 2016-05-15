classdef AlexnetFc8Classifier < AlexnetClassifier
    % Classifier based on Alexnet feature-extraction.
    % Uses a linear classifier on top of the Alexnet fc8 output.
    
    methods
        function obj = AlexnetFc8Classifier()
            fc8OutputLength = 1000;
            obj = obj@AlexnetClassifier(fc8OutputLength);
        end
        
        function name = getName(~)
            name = 'alexnet-fc8';
        end
        
        function features = getImageFeatures(self, image)
            features = getFc8Output(self.netParams, image);
        end
    end
end
