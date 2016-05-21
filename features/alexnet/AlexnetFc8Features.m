classdef AlexnetFc8Features < AlexnetFeatures
    % Extract Alexnet fc8 features
    
    methods
        function obj = AlexnetFc8Features()
            fc8OutputLength = 1000;
            obj = obj@AlexnetFeatures(fc8OutputLength);
        end
        
        function name = getName(~)
            name = 'alexnet-fc8';
        end
        
        function features = getImageFeatures(self, image)
            features = getFc8Output(self.netParams, image);
        end
    end
end
