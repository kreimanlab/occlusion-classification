classdef FeatureProvidingClassifier < Classifier
    % Classifier that retrieves the features from previous runs.
    
    properties
        classifier
        caches
        loadFeatures
    end
    
    methods
        function self = FeatureProvidingClassifier(...
                occlusionData, dataSelection, classifier)
            self.classifier = classifier;
            dir = './data/OcclusionModeling/features/';
            [filePrefix, fileSuffix, loadFeatures] = ...
                self.getFileDirectives(classifier);
            self.caches = containers.Map(...
                {char(RunType.Train), char(RunType.Test)}, ...
                {self.createWholeCache(...
                [dir 'klab325_orig/'], ...
                filePrefix, fileSuffix, loadFeatures, dataSelection, ...
                occlusionData), ...
                self.createOccludedCache(...
                [dir 'data_occlusion_klab325v2/'], ...
                filePrefix, fileSuffix, loadFeatures, dataSelection)});
        end
        
        function name = getName(self)
            name = self.classifier.getName();
        end
        
        function fit(self, features, labels)
            self.classifier.fit(features,labels);
        end
        
        function labels = predict(self, features)
            labels = self.classifier.predict(features);
        end
        
        function features = extractFeatures(self, ids, runType)
            boxedFeatures = cell(length(ids), 1);
            cache = self.caches(char(runType));
            for i = 1:length(ids)
                cachedFeatures = cache(ids(i));
                boxedFeatures{i} = cachedFeatures{:};
            end
            features = cell2mat(boxedFeatures);
        end
    end
    
    methods (Access=private)
        function cache = createWholeCache(~, ...
                dir, filePrefix, fileSuffix, ...
                loadFeatures, dataSelection, occlusionData)
            cache = containers.Map(...
                'KeyType', 'double', 'ValueType', 'any');
            filePath = [dir filePrefix '1-325' fileSuffix];
            features = loadFeatures(filePath);
            for id = dataSelection
                cache(id) = {features(occlusionData.pres(id), :)};
            end
        end
        
        function cache = createOccludedCache(~, ...
                dir, filePrefix, fileSuffix, ...
                loadFeatures, dataSelection)
            cache = containers.Map(...
                'KeyType', 'double', 'ValueType', 'any');
            minFile = 1000 * floor(min(dataSelection) / 1000) + 1;
            maxFile = 1000 * ceil(max(dataSelection) / 1000) + 1;
            for fileLower = minFile:1000:maxFile-1000
                fileUpper = fileLower+999;
                filePath = [dir filePrefix num2str(fileLower) '-' ...
                    num2str(fileUpper) fileSuffix];
                features = loadFeatures(filePath);
                for id = dataSelection(dataSelection >= fileLower ...
                        & dataSelection <= fileUpper)
                    cache(id) = {features(id - fileLower + 1, :)};
                end
            end
        end
        
        function features = loadHmax(~, filePath)
            data = load(filePath);
            features = data.features;
        end
        
        function [filePrefix, fileSuffix, loadFeatures] = ...
                getFileDirectives(self, classifier)
            switch(classifier.getName())
                case 'alexnet-pool5'
                    filePrefix = 'caffenet_pool5_ims_';
                    fileSuffix = '.txt';
                    loadFeatures = @(file) dlmread(file, ' ', 0, 1);
                case 'alexnet-fc7'
                    filePrefix = 'caffenet_fc7_ims_';
                    fileSuffix = '.txt';
                    loadFeatures = @(file) dlmread(file, ' ', 0, 1);
                case 'hmax'
                    filePrefix = 'hmax_ims_';
                    fileSuffix = '.mat';
                    loadFeatures = @self.loadHmax;
                otherwise
                    error(['Unknown classifier ' classifier.getName()]);
            end
        end
    end
end
