classdef RnnFeatures < FeatureExtractor
    %RNNFEATURES Feature extractor for a RNN layer on top of other features
    % output_{t+1} = activation(previousFeatures + W .* output_t)
    
    properties
        timesteps
        featuresInput
        weights
        activation = @(x) max(0, x)
    end
        
    methods
        function obj = RnnFeatures(timesteps, featuresInput)
            obj.timesteps = timesteps;
            obj.featuresInput = featuresInput;
        end
        
        function name = getName(~)
            name = 'RNN';
        end
        
        function previousFeatures = extractFeatures(self, rows, runType, labels)
            previousFeatures = self.featuresInput.extractFeatures(rows, runType, labels);
            if isempty(self.weights)
                self.weights = self.createWeights(size(previousFeatures, 2));
            end
            W = repmat(self.weights, size(previousFeatures, 1), 1);
            features = previousFeatures;
            for t = 1:self.timesteps
                features = self.activation(previousFeatures + W .* features);
            end
        end
        
        function weights = createWeights(~, ~)
            error('Not implemented');
        end
    end
end
