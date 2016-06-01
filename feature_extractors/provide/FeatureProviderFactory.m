classdef FeatureProviderFactory < handle
    % Caches feature providers to minimize memory overhead.
    
    properties
        featureProviders
        occlusionData
        dataSelection
    end
    
    methods
        function self = FeatureProviderFactory(occlusionData, dataSelection)
            self.occlusionData = occlusionData;
            self.dataSelection = dataSelection;
            self.featureProviders = containers.Map();
        end
        
        function featureProvider = get(self, originalExtractor)
            name = originalExtractor.getName();
            if isKey(self.featureProviders, name)
                featureProvider = self.featureProviders(name);
                return;
            end
            featureProvider = FeatureProvider(...
                self.occlusionData, self.dataSelection, originalExtractor);
            self.featureProviders(name) = featureProvider;
        end
    end
end
