classdef HopFeatures < FeatureExtractor
    % Attachment for another feature extractor to post-processes the
    % features with a hopfield network.
    % Initializes itself when asked to extract train features.
    
    properties
        featuresInput
        net
        netTrained
        timesteps = 50
    end
    
    methods
        function obj = HopFeatures(featuresInput)
            obj.featuresInput = featuresInput;
            obj.netTrained = false;
        end
    
        function name = getName(self)
            name = [self.featuresInput.getName() '-hop_t' ...
                num2str(self.timesteps)];
        end
        
        function features = extractFeatures(self, rows, runType, labels)
            previousFeatures = self.featuresInput.extractFeatures(...
                rows, runType, labels);
            if runType == RunType.Train
                % train network
                T = previousFeatures';
                self.net = newhop(T);
                self.netTrained = true;
                features = T';
            elseif runType == RunType.Test
                if ~self.netTrained
                    error('net was not trained yet');
                end
                % retrieve from network
                features = zeros(size(previousFeatures));
                for i = 1:size(features, 1)
                    y = self.net({1 self.timesteps}, {}, ...
                        {previousFeatures(i, :)'});
                    T = y{self.timesteps};
                    features(i,:) = T';
                end
            end
        end
    end
end
