classdef AlexnetPool5ClassifierKlabData < AlexnetPool5Classifier
    % Classifier based on Alexnet feature-extraction (klab data)
    
    methods
        function obj = AlexnetPool5ClassifierKlabData()
            obj = obj@AlexnetPool5Classifier();
            obj.featuresLength = 9217;
        end
    end
end

