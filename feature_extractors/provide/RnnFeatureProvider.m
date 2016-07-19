classdef RnnFeatureProvider < FeatureExtractor
    % Classifier that retrieves the RNN features from previous runs.
    % The format for the RNN is fundamentally different from the other
    % features (i.e. not split up into multiple files).
    
    properties
        occlusionData
        originalExtractor
        features
    end
    
    methods
        function self = RnnFeatureProvider(...
                occlusionData, originalExtractor)
            self.occlusionData = occlusionData;
            self.originalExtractor = originalExtractor;
            self.features = self.loadFeatures(self.originalExtractor);
        end
        
        function name = getName(self)
            name = self.originalExtractor.getName();
        end
        
        function features = extractFeatures(self, ids, runType, ~)
            switch(runType)
                case RunType.Train
                    features = self.features(...
                        self.occlusionData.pres(ids), :);
                case RunType.Test
                    features = self.features(325 + ids, :);
            end
        end
    end
    
    methods (Access = private)
        function features = loadFeatures(self, originalExtractor)
            [featuresFile, filetype] = self.findFeaturesFile(...
                originalExtractor.getName());
            if strcmp(filetype, 'mat')
                features = load(featuresFile);
                features = features.features;
            elseif strcmp(filetype, 'txt')
                features = dlmread(featuresFile, ' ');
            else
                error('Unknown filetype %s', filetype);
            end
        end
        
        function [featuresFile, filetype] = ...
                findFeaturesFile(~, extractorName)
            dir = getFeaturesDirectory();
            possibleExtensions = {'mat', 'txt'};
            for filetype = possibleExtensions
                featuresFile = [dir, extractorName, '.', filetype{:}];
                if exist(featuresFile, 'file') == 2
                    return;
                end
            end
            error('file %s not found in directory %s', extractorName, dir);
        end
    end
end
