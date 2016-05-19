classdef PixelClassifier < Classifier
    % Classifier based on pixels only
    
    methods
        function obj = PixelClassifier()
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
