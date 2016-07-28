classdef AlexnetPool5Features < AlexnetFeatures
    % Extract Alexnet pool5 features
    
    methods
        function obj = AlexnetPool5Features()
            pool5OutputLength = 9216;
            obj = obj@AlexnetFeatures(pool5OutputLength);
        end
        
        function name = getName(~)
            name = 'alexnet-pool5';
        end
        
        function features = getImageFeatures(self, image)
            features = getPool5Output(self.netParams, image);
        end
    end
end

