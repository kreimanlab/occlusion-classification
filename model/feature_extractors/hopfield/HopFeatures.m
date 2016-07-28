classdef HopFeatures < FeatureExtractor
    % Attachment for another feature extractor to post-processes the
    % features with a hopfield network.
    % Initializes itself when asked to extract train features.
    
    properties
        featuresInput
        net
        netTrained
        timesteps
    end
    
    methods
        function obj = HopFeatures(timesteps, featuresInput)
            obj.timesteps = timesteps;
            obj.featuresInput = featuresInput;
            obj.netTrained = false;
        end
    
        function name = getName(self)
            name = [self.featuresInput.getName() '-hop_t' ...
                num2str(self.timesteps)];
        end
        
        function [features, ys] = extractFeatures(self, rows, ...
                runType, labels)
            previousFeatures = self.featuresInput.extractFeatures(...
                rows, runType, labels);
            if runType == RunType.Train
                % train network
                self.net = self.trainNet(previousFeatures);
                features = previousFeatures;
            elseif runType == RunType.Test
                if ~self.netTrained
                    error('net was not trained yet');
                end
                % retrieve from network
                features = zeros(size(previousFeatures));
                ys = NaN([size(previousFeatures), self.timesteps]);
                for i = 1:size(features, 1)
                    y = self.net({1 self.timesteps}, {}, ...
                        {previousFeatures(i, :)'});
                    ys(i, :, :) = cell2mat(y);
                    T = y{self.timesteps};
                    features(i, :) = T';
                end
            end
        end
        
        function net = trainNet(self, features)
            T = features';
            net = newhop(T);
            self.netTrained = true;
        end
    end
end
