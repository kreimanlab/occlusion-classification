classdef RnnFeatures < FeatureExtractor
    % Feature extractor for a RNN layer on top of other features
    
    methods
        function obj = RnnFeatures()
        end
        
        function name = getName(~)
            name = 'rnn';
        end
        
        function features = extractFeatures(~, ~, ~, ~)
            error('Not implemented');
        end
    end
end
