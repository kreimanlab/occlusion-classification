classdef AlexnetFc7FeaturesKlabData < AlexnetFc7Features
    % Extract KLAB Alexnet fc7 features
    
    methods
        function obj = AlexnetFc7FeaturesKlabData()
            obj = obj@AlexnetFc7Features();
            obj.featuresLength = 4097;
        end
    end
end

