classdef HopFeaturesShuffledWeights < HopFeatures
    % Shuffle the weights after training
    
    methods
        function obj = HopFeaturesShuffledWeights(timesteps, featuresInput)
            obj@HopFeatures(timesteps, featuresInput);
        end
    
        function name = getName(self)
            name = [getName@HopFeatures(self) '_shuffled'];
        end
        
        function net = trainNet(self, features)
            net = trainNet@HopFeatures(self, features);
            net = shuffle_hop(net);
        end
    end
end
