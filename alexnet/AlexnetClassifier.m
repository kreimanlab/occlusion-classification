classdef AlexnetClassifier < Classifier
    % Classifier based on Alexnet feature-extraction
    % Uses a linear classifier on top of the Alexnet fc7 output
    
    properties(Constant)
        FC7OUTPUT_LENGTH = 4096;
    end
    properties
        netParams
        imagesMean
        classifier
    end
    
    methods
        function obj = AlexnetClassifier()
            dir = fileparts(mfilename('fullpath'));
            obj.netParams = load([dir '/ressources/alexnetParams.mat']);
            % obtained from https://drive.google.com/file/d/0B-VdpVMYRh-pQWV1RWt5NHNQNnc/view
            
            imagesMeanData = load([dir '/ressources/ilsvrc_2012_mean.mat']);
            obj.imagesMean = imagesMeanData.mean_data;
        end
        
        function name = getName(~)
            name = 'alexnet';
        end
        
        function features = extractFeatures(self, images)
            features = self.getImageFc7Outputs(images);
        end
        
        function fit(self, features, labels)
            self.classifier = fitcecoc(features,labels);
        end
        
        function labels = predict(self, features)
            labels = self.classifier.predict(...
                reshape(features, [size(features, 1) self.FC7OUTPUT_LENGTH]));
        end
        
        function fc7 = getImageFc7Outputs(self, images)
            fc7 = zeros(length(images), self.FC7OUTPUT_LENGTH);
            for img=1:length(images)
                data = prepareGrayscaleImage(images{img}, self.imagesMean);
                fc7Single = getFc7Output(self.netParams, data);
                fc7(img, :) = fc7Single(:);
            end
        end
    end
end
