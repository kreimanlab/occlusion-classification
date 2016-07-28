classdef AlexnetFc7Features < AlexnetFeatures
    % Extract Alexnet fc7 features
    
    properties
        pool5FeatureExtractor
    end
    
    methods
        function obj = AlexnetFc7Features()
            fc7OutputLength = 4096;
            obj = obj@AlexnetFeatures(fc7OutputLength);
            obj.pool5FeatureExtractor = AlexnetPool5Features(obj.netParams);
        end
        
        function name = getName(~)
            name = 'alexnet-fc7';
        end
        
        function features = getImageFeatures(self, image)
            % Preparation
            fc6Weights=self.netParams.weights(6).weights{1};
            fc6Bias=self.netParams.weights(6).weights{2};
            fc7Weights=self.netParams.weights(7).weights{1};
            fc7Bias=self.netParams.weights(7).weights{2};
            % pass image through network
            pool5_2d = self.pool5FeatureExtractor.getImageFeatures(image);
            fc6 = fc(pool5_2d, fc6Weights, fc6Bias);
            relu6 = relu(fc6);
            dropout6 = dropout(relu6);
            fc7 = fc(dropout6, fc7Weights, fc7Bias);
            relu7 = relu(fc7);
            dropout7 = dropout(relu7);
            
            features = dropout7;
        end
    end
end