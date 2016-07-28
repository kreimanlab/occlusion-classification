classdef AlexnetWFc6Features < AlexnetFeatures
    % Extract Alexnet W_{fc6->fc7} * fc6 features
    
    properties
        pool5FeatureExtractor
    end
    
    methods
        function obj = AlexnetWFc6Features()
            obj = obj@AlexnetFeatures(4096);
            obj.pool5FeatureExtractor = AlexnetPool5Features(obj.netParams);
        end
        
        function name = getName(~)
            name = 'alexnet-Wfc6';
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
            
            features = fc7;
        end
    end
end
