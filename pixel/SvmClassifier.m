classdef SvmClassifier < Classifier
    % Classifier based on pixels only
    
    properties
        classifier
    end
    
    methods
        function obj = SvmClassifier()
        end
        
        function name = getName(~)
            name = 'svm';
        end
        
        function features = extractFeatures(~, images)
            features = zeros(length(images), numel(images{1}));
            for i = 1:length(images)
                flatPixels = reshape(images{i}, [1 numel(images{i})]);
                features(i, :) = flatPixels(:);
            end
        end
        
        function fit(self, features, labels)
            self.classifier = fitcecoc(features, labels);
        end
        
        function labels = predict(self, features)
            labels = self.classifier.predict(features);
        end
    end
end
