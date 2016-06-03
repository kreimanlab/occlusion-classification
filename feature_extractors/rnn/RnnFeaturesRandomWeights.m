classdef RnnFeaturesRandomWeights < RnnFeatures
    % RNN with random weights
    % out_{t+1} = activation(in, W * out_t)
    
    methods
        function obj = RnnFeaturesRandomWeights(timesteps, featuresInput)
            obj@RnnFeatures(timesteps, featuresInput);
        end
        
        function name = getName(self)
            name = [getName@RnnFeatures(self) '_rand'];
        end
        
        function weights = createWeights(~, len)
            weights = rand(1, len);
        end
    end
end
