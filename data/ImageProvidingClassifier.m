classdef ImageProvidingClassifier < Classifier
    % Classifier that provides images for a given id.
    
    properties
        data
        classifier
        images
    end
    
    methods
        function self = ImageProvidingClassifier(data, classifier)
            self.data = data;
            self.classifier = classifier;
            data = load('KLAB325.mat');
            self.images = data.img_mat;
        end
        
        function name = getName(self)
            name = self.classifier.getName();
        end
        
        function fit(self, features, labels)
            self.classifier.fit(features,labels);
        end
        
        function labels = predict(self, features)
            labels = self.classifier.predict(features);
        end
        
        function features = extractFeatures(self, dataSelection)
            images = self.images(self.data.pres(dataSelection));
            features = self.classifier.extractFeatures(images);
        end
    end
end
