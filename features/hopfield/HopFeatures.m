classdef HopFeatures < FeatureExtractor
    % Attachment for another feature extractor to post-processes the
    % features with a hopfield network.
    % Initializes itself with the first test dataset.
    
    properties
        featuresInput
        net
        netTrained
        timesteps = 10
        downsampledLength
    end
    
    methods
        function obj = HopFeatures(downsampledLength, featuresInput)
            obj.downsampledLength = downsampledLength;
            obj.featuresInput = featuresInput;
            obj.netTrained = false;
        end
        
        function name = getName(self)
            name = [self.featuresInput.getName() '-hop'];
        end
        
        function features = extractFeatures(self, rows, runType)
            previousFeatures = self.featuresInput.extractFeatures(rows, runType);
            previousFeatures = self.downsample(previousFeatures);
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
    
    methods(Access = private)
        function downsampledFeatures = downsample(self, features)
            sampleSteps = ceil(size(features, 2) / self.downsampledLength);
            downsampledFeatures = zeros(size(features, 1), ...
                ceil(size(features, 2) / sampleSteps));
            for i = 1:size(features, 1)
                downsampledFeatures(i, :) = downsample(features(i, :), ...
                    sampleSteps);
            end
        end
    end
end

