classdef HmaxFeatures < FeatureExtractor
    % Extracts features using HMAX.
    
    methods
        function obj = HmaxFeatures()
        end
        
        function name = getName(~)
            name = 'hmax';
        end
        
        function features = extractFeatures(~, images, ~)
            c2 = runHmax(images);
            features = poolC2(c2);
            assert(length(images) == size(features, 1));
        end
    end
end

