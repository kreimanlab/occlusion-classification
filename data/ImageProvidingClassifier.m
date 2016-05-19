classdef ImageProvidingClassifier < Classifier
    % Classifier that provides images for a given id.
    
    properties
        data
        providedClassifier
        images
    end
    
    methods
        function self = ImageProvidingClassifier(data, providedClassifier)
            self.data = data;
            self.providedClassifier = providedClassifier;
            data = load('KLAB325.mat');
            self.images = data.img_mat;
        end
        
        function name = getName(self)
            name = self.providedClassifier.getName();
        end
        
        function fit(self, features, labels)
            self.providedClassifier.fit(features,labels);
        end
        
        function labels = predict(self, features)
            labels = self.providedClassifier.predict(features);
        end
        
        function features = extractFeatures(self, dataSelection, runType)
            imgs = self.images(self.data.pres(dataSelection));
            if runType == RunType.Test
                imgs = occlude(imgs, dataSelection, self.data);
            end
            features = self.providedClassifier.extractFeatures(imgs, runType);
        end
    end
end
