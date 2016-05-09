classdef HmaxClassifier < Classifier
    % Classifier based on HMAX feature-extraction
    % Uses a linear classifier on top of the HMAX features
    
    properties
        classifier
    end
    
    methods
        function obj = HmaxClassifier()
        end
        
        function name = getName(~)
            name = 'hmax';
        end
        
        function features = extractFeatures(~, images)
            c2 = runHmax(images);
            features = poolC2(c2);
            assert(length(images) == size(features, 1));
        end
        
        function fit(self, features, labels)
            self.classifier = fitcecoc(features,labels);
        end
        
        function labels = predict(self, features)
            labels = self.classifier.predict(features);
        end
    end
end

