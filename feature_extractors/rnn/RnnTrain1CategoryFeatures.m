classdef RnnTrain1CategoryFeatures < FeatureExtractor
    %RNNFEATURES Dummy Feature extractor for a RNN layer on top of other 
    %features that has been trained on one category only.
    
    properties
        timesteps
        trainCategory % the category that the RNN was trained on
    end
        
    methods
        function obj = RnnTrain1CategoryFeatures(timesteps, trainCategory)
            obj.timesteps = timesteps;
            obj.trainCategory = trainCategory;
        end
        
        function name = getName(self)
            name = sprintf('train1cat/split-%d_t-%d/features', ...
                self.trainCategory - 1, self.timesteps);
        end
        
        function extractFeatures(~, ~, ~, ~)
            error('Not implemented');
        end
    end
end
