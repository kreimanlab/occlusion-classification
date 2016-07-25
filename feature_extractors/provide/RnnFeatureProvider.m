classdef RnnFeatureProvider < FeatureExtractor
    % Classifier that retrieves the RNN features from previous runs.
    % The format for the RNN is fundamentally different from the other
    % features (i.e. not split up into multiple files).
    
    properties
        occlusionData
        originalExtractor
        trainFeatures % unmodified whole
        testFeatures % RNN'ed occluded+whole
    end
    
    methods
        function self = RnnFeatureProvider(...
                occlusionData, originalExtractor)
            self.occlusionData = occlusionData;
            self.originalExtractor = originalExtractor;
            self.trainFeatures = self.loadTrainFeatures();
            self.testFeatures = ...
                self.loadTestFeatures(self.originalExtractor);
        end
        
        function name = getName(self)
            name = self.originalExtractor.getName();
        end
        
        function features = extractFeatures(self, rows, runType, ~)
            switch(runType)
                case RunType.Train
                    features = self.trainFeatures(...
                        self.occlusionData.pres(rows), :);
                case RunType.Test
                    features = self.testFeatures(rows, :);
            end
        end
    end
    
    methods (Access = private)
        function features = loadTestFeatures(self, originalExtractor)
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
            
            if size(features, 1) == 13325
                features = [features(326:end, :); features(1:325, :)];
            else
                warning('feature size %d does not match data size %d', ...
                    size(features, 1), size(self.occlusionData, 1));
            end
        end
        
        function features = loadTrainFeatures(~)
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
