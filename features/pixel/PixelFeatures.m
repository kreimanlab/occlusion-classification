classdef PixelFeatures < FeatureExtractor
    % Extracts a raw pixel vector
    
    methods
        function obj = PixelFeatures()
        end
        
        function name = getName(~)
            name = 'pixels';
        end
        
        function features = extractFeatures(~, images, ~)
            features = zeros(length(images), numel(images{1}));
            for i = 1:length(images)
                flatPixels = reshape(images{i}, [1 numel(images{i})]);
                features(i, :) = flatPixels(:);
            end
        end
    end
end
