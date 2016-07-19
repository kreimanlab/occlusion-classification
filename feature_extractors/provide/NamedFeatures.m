classdef NamedFeatures < FeatureExtractor
    %NAMEDFEATURES Only provide the name, no other implementation
    
    properties
        name
    end
    
    methods
        function obj = NamedFeatures(name)
            obj.name = name;
        end
        
        function name = getName(self)
            name = self.name;
        end
        
        function extractFeatures(~, ~, ~, ~)
            error('not implemented');
        end
    end
end
