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
            if strfind(class(originalExtractor), 'Rnn') == 1
                featureProvider = RnnFeatureProvider(...
                    self.occlusionData, originalExtractor);
            else
                if isa(originalExtractor, 'BipolarFeatures')
                    inputProvider = FeatureProvider(...
                        self.occlusionData, self.dataSelection, ...
                        originalExtractor.featuresInput);
                    originalExtractor.featuresInput = inputProvider;
                    featureProvider = originalExtractor;
                else
                    featureProvider = FeatureProvider(...
                        self.occlusionData, self.dataSelection, ...
                        originalExtractor);
                end
            end
            self.featureProviders(name) = featureProvider;
        end
        
        function remove(self, originalExtractor)
            name = originalExtractor.getName();
            name = strrep(name, 'caffenet_fc7', 'alexnet-fc7');
            if ~isKey(self.featureProviders, name)
                error('Unknown extractor %s', name);
            end
            remove(self.featureProviders, {name});
        end
    end
end
