classdef FeatureProvider < FeatureExtractor
    % Classifier that retrieves the features from previous runs.
    
    properties
        originalExtractor
        caches
    end
    
    methods
        function self = FeatureProvider(trainDirectory, testDirectory, ...
                objectForRow, dataSelection, originalExtractor)
            self.originalExtractor = originalExtractor;
            [filePrefix, fileSuffix, loadFeatures] = ...
                self.getFileDirectives(originalExtractor);
            trainCache = self.createTrainCache(trainDirectory, ...
                filePrefix, fileSuffix, loadFeatures, objectForRow);
            testCache = self.createTestCache(testDirectory, ...
                filePrefix, fileSuffix, loadFeatures, dataSelection);
            self.caches = containers.Map(...
                {char(RunType.Train), char(RunType.Test)}, ...
                {trainCache, testCache});
        end
        
        function name = getName(self)
            name = self.originalExtractor.getName();
            name = strrep(name, 'alexnet-', 'caffenet_');
        end
        
        function features = extractFeatures(self, rows, runType, ~)
            boxedFeatures = cell(length(rows), 1);
            cache = self.caches(char(runType));
            for i = 1:length(rows)
                cachedFeatures = cache(rows(i));
                boxedFeatures{i} = cachedFeatures{:};
            end
            features = cell2mat(boxedFeatures);
        end
    end
    
    methods (Access=private)
        function cache = createTrainCache(~, ...
                dir, filePrefix, fileSuffix, ...
                loadFeatures, objectForRow)
            cache = containers.Map(...
                'KeyType', 'double', 'ValueType', 'any');
            filePath = [dir, filePrefix, '1-325', fileSuffix];
            features = loadFeatures(filePath);
            for row = 1:size(objectForRow, 1)
                cache(row) = {features(objectForRow(row), :)};
            end
        end
        
        function cache = createTestCache(~, ...
                dir, filePrefix, fileSuffix, ...
                loadFeatures, dataSelection)
            cache = containers.Map(...
                'KeyType', 'double', 'ValueType', 'any');
            minFile = 1000 * floor(min(dataSelection) / 1000) + 1;
            for fileLower = minFile:1000:max(dataSelection)
                fileUpper = min(fileLower + 999, max(dataSelection));
                filePath = [dir, filePrefix, num2str(fileLower), '-', ...
                    num2str(fileUpper), fileSuffix];
                features = loadFeatures(filePath);
                for id = dataSelection(dataSelection >= fileLower ...
                        & dataSelection <= fileUpper)
                    cache(id) = {features(id - fileLower + 1, :)};
                end
            end
        end
        
        function features = loadMat(~, filePath)
            data = load(filePath);
            features = data.features;
        end
        
        function [filePrefix, fileSuffix, loadFeatures] = ...
                getFileDirectives(self, originalExtractor)
            name = originalExtractor.getName();
            switch(name)
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
                    loadFeatures = @self.loadMat;
                otherwise
                    filePrefix = [strrep(name, 'alexnet-', 'caffenet_') '_'];
                    fileSuffix = '.mat';
                    loadFeatures = @self.loadMat;
            end
        end
    end
end
