classdef MaskedImageProvider < ImageProvider
    % Provides masked images for a given dataset row
    
    methods
        function obj = MaskedImageProvider(data, consumer)
            obj = obj@ImageProvider(data, consumer);
        end
        
        function name = getName(self)
            name = [self.consumer.getName(), '-masked'];
        end
        
        function features = extractFeatures(self, dataSelection, ...
                runType, labels)
            imgs = self.getImages(dataSelection, runType);
            for i = 1:numel(imgs)
                imgs{i} = createPhaseScramble(...
                    size(imgs{i}), self.averageSpectra);
            end
            features = self.consumer.extractFeatures(imgs, runType, labels);
        end
    end
end
