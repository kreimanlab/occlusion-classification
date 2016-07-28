classdef ImageProvider < FeatureExtractor
    % Provides images for a given dataset row
    
    properties
        data
        consumer
        images
    end
    
    methods
        function self = ImageProvider(data, consumer)
            self.data = data;
            self.consumer = consumer;
            data = load('KLAB325.mat');
            self.images = data.img_mat;
        end
        
        function name = getName(self)
            name = self.consumer.getName();
        end
        
        function features = extractFeatures(self, dataSelection, ...
                runType, labels)
            imgs = self.images(self.data.pres(dataSelection));
            if runType == RunType.Test
                imgs = occlude(imgs, dataSelection, self.data);
            end
            features = self.consumer.extractFeatures(imgs, runType, labels);
        end
    end
end
