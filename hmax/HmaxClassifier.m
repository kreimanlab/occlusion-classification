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
            features = runHmax(images);
        end
        
        function fit(self, features, labels)
            c2Pooled = poolC2(features);
            assert(length(labels) == size(c2Pooled,1));
            self.classifier = fitcecoc(c2Pooled,labels);
        end
        
        function labels = predict(self, features)
            c2Pooled = poolC2(features);
            labels = self.classifier.predict(c2Pooled);
        end
    end
end

