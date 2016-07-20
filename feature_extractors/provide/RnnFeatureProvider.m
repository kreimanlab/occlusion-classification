classdef RnnFeatureProvider < FeatureExtractor
    % Classifier that retrieves the RNN features from previous runs.
    % The format for the RNN is fundamentally different from the other
    % features (i.e. not split up into multiple files).
    
    properties
        occlusionData
        originalExtractor
        wholeFeatures
        occludedFeatures
    end
    
    methods
        function self = RnnFeatureProvider(...
                occlusionData, originalExtractor)
            self.occlusionData = occlusionData;
            self.originalExtractor = originalExtractor;
            self.wholeFeatures = self.loadWholeFeatures();
            self.occludedFeatures = ...
                self.loadOccludedFeatures(self.originalExtractor);
        end
        
        function name = getName(self)
            name = self.originalExtractor.getName();
        end
        
        function features = extractFeatures(self, ids, runType, ~)
            switch(runType)
                case RunType.Train
                    features = self.wholeFeatures(...
                        self.occlusionData.pres(ids), :);
                case RunType.Test
                    features = self.occludedFeatures(ids, :);
            end
        end
    end
    
    methods (Access = private)
        function features = loadOccludedFeatures(self, originalExtractor)
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
            
            if size(features, 1) == 13000
                return;
            elseif size(features, 1) == 13325
                features = features(326:end, :);
            else
                error('unknown feature size %d', size(features, 1));
            end
        end
        
        function features = loadWholeFeatures(~)
            dir = getFeaturesDirectory();
            fc7File = [dir, 'klab325_orig/caffenet_fc7_ims_1-325.txt'];
            features = dlmread(fc7File, ' ', 0, 1);
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
