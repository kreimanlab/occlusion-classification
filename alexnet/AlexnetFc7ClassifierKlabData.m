classdef AlexnetFc7ClassifierKlabData < AlexnetFc7Classifier
    % Classifier based on Alexnet feature-extraction (klab data)
    
    methods
        function obj = AlexnetFc7ClassifierKlabData()
            obj = obj@AlexnetFc7Classifier();
            obj.featuresLength = 4097;
        end
    end
end

