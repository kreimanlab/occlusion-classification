classdef HumanReplayClassifier < Classifier
    % Classifier outputting the human predictions
    
    properties
        dataset
    end
    
    methods
        function obj = HumanReplayClassifier(dataset)
            obj@Classifier([]);
            obj.dataset = dataset;
        end
        
        function name = getName(~)
            name = 'human';
        end
        
        function train(~, ~, ~)
        end
        
        function labels = predict(self, rows)
            labels = self.dataset.response_category(rows);
        end
        
        function fit(~, ~, ~)
        end
        
        function classify(~, ~)
        end
    end
end
