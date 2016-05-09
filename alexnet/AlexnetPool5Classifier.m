classdef AlexnetPool5Classifier < AlexnetClassifier
    % Classifier based on Alexnet feature-extraction
    % Uses a linear classifier on top of the Alexnet pool5 output
    
    methods
        function obj = AlexnetPool5Classifier()
            pool5OutputLength = 9216;
            obj = obj@AlexnetClassifier(pool5OutputLength);
        end
        
        function name = getName(~)
            name = 'alexnet-pool5';
        end
        
        function features = getImageFeatures(self, image)
            features = getPool5Output(self.netParams, image);
        end
    end
end

