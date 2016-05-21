classdef AlexnetFc7Features < AlexnetFeatures
    % Extract Alexnet fc7 features
    
    methods
        function obj = AlexnetFc7Features()
            fc7OutputLength = 4096;
            obj = obj@AlexnetFeatures(fc7OutputLength);
        end
        
        function name = getName(~)
            name = 'alexnet-fc7';
        end
        
        function features = getImageFeatures(self, image)
            features = getFc7Output(self.netParams, image);
        end
    end
end
