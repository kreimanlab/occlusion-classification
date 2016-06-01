classdef AlexnetFeatures < FeatureExtractor
    % Extract Alexnet features
    
    properties
        featuresLength
        netParams
        imagesMean
    end
    
    methods
        function obj = AlexnetFeatures(featuresLength)
            obj.featuresLength = featuresLength;
            
            dir = fileparts(mfilename('fullpath'));
            obj.netParams = load([dir '/ressources/alexnetParams.mat']);
            % obtained from https://drive.google.com/file/d/0B-VdpVMYRh-pQWV1RWt5NHNQNnc/view
            imagesMeanData = load([dir '/ressources/ilsvrc_2012_mean.mat']);
            obj.imagesMean = imagesMeanData.mean_data;
        end
        
        function features = extractFeatures(self, images, ~, ~)
            features = zeros(length(images), self.featuresLength);
            for img=1:length(images)
                preparedImage = prepareGrayscaleImage(images{img}, self.imagesMean);
                imageFeatures = self.getImageFeatures(preparedImage);
                features(img, :) = imageFeatures(:);
            end
            features = reshape(features, [size(features, 1), ...
                numel(features) / size(features, 1)]);
        end
    end
    
    methods(Abstract)
        getImageFeatures(self, image, runType)
    end
end
