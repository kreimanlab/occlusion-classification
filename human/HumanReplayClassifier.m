classdef HumanReplayClassifier < Classifier
    % Classifier outputting the human predictions
    
    properties
        dataset
    end
    
    methods
        function obj = HumanReplayClassifier(dataset)
            obj.dataset = dataset;
        end
        
        function name = getName(~)
            name = 'human';
        end
        
        function features = extractFeatures(~, rows, ~)
            features = rows;
        end
        
        function fit(~, ~, ~)
        end
        
        function labels = predict(self, rows)
            labels = self.dataset.response_category(rows);
        end
    end
end
