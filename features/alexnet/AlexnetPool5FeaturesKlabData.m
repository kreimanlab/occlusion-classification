classdef AlexnetPool5FeaturesKlabData < AlexnetPool5Features
    % Use KLAB extracted Alexnet-pool5 features
    
    methods
        function obj = AlexnetPool5FeaturesKlabData()
            obj = obj@AlexnetPool5Features();
            obj.featuresLength = 9217;
        end
    end
end

