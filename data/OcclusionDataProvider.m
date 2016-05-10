classdef OcclusionDataProvider
    %OCCLUSIONDATAPROVIDER Provides occlusion data for image
    
    properties
        occlusionData
        imageToDataIndex
    end
    
    methods
        function obj = OcclusionDataProvider(images, dataSelection)
            imagesHashes = arrayfun(@(image) hashImage(image), ...
                images, 'UniformOutput', false);
            obj.occlusionData = obj.prepareOcclusionData(dataSelection);
            obj.imageToDataIndex = containers.Map(imagesHashes, ...
                1:length(dataSelection));
        end
        
        function occlusionData = get(self, images)
            imagesHashes = arrayfun(@(image) hashImage(image), ...
                images, 'UniformOutput', false);
            dataIndices = values(self.imageToDataIndex, imagesHashes);
            occlusionData = self.occlusionData(cell2mat(dataIndices), :);
        end
    end
    
    methods(Access = private)
        function occlusionData = prepareOcclusionData(~, dataSelection)
            dir = fileparts(mfilename('fullpath'));
            occlusionData = load([dir '/data_occlusion_main.mat']);
            occlusionData = occlusionData.data(dataSelection, :);
        end
    end
end

