classdef CategoryMedianFeatures < FeatureExtractor
    % reduce the input features to the category median for training
    
    properties
        featuresInput
    end
    
    methods
        function obj = CategoryMedianFeatures(featuresInput)
            obj.featuresInput = featuresInput;
        end
    
        function name = getName(self)
            name = [self.featuresInput.getName() '-category_median'];
        end
        
        function features = extractFeatures(self, rows, runType, labels)
            features = self.featuresInput.extractFeatures(rows, runType);
            if runType == RunType.Train
                uniqueLabels = unique(labels);
                accumulatedFeatures = ...
                    zeros(length(labels), size(features, 2));
                for i = 1:length(uniqueLabels)
                    relevantRows = labels == uniqueLabels(i);
                    categoryCenter = median(features(relevantRows, :), 1);
                    categoryCenter(categoryCenter == 0) = 1;
                    accumulatedFeatures(relevantRows, :) = ...
                        repmat(categoryCenter, sum(relevantRows), 1);
                end
                features = accumulatedFeatures;
            end
        end
    end
end
