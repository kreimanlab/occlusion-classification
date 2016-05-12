classdef FeatureProvidingClassifier < Classifier
    % Classifier that retrieves the features from previous runs.
    
    properties
        classifier
        cache
        loadFeatures
    end
    
    methods
        function self = FeatureProvidingClassifier(dataSelection, classifier)
            self.classifier = classifier;
            dir = './data/OcclusionModeling/features/data_occlusion_klab325v2/';
            switch(classifier.getName())
                case 'alexnet-pool5'
                    filePrefix = 'caffenet_pool5_ims_';
                    fileSuffix = '.txt';
                    self.loadFeatures = @self.loadCaffenet;
                case 'alexnet-fc7'
                    filePrefix = 'caffenet_fc7_ims_';
                    fileSuffix = '.txt';
                    self.loadFeatures = @self.loadCaffenet;
                case 'hmax'
                    filePrefix = 'hmax_ims_';
                    fileSuffix = '.mat';
                    self.loadFeatures = @self.loadHmax;
                otherwise
                    error(['Unknown classifier ' classifier.getName()]);
            end
            self.setupCache(dir, filePrefix, fileSuffix, dataSelection);
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
        
        function features = extractFeatures(self, ids)
            boxedFeatures = cell(length(ids), 1);
            for i = 1:length(ids)
                cachedFeatures = self.cache(ids(i));
                boxedFeatures{i} = cachedFeatures{:};
            end
            features = cell2mat(boxedFeatures);
        end
    end
    
    methods (Access=private)
        function setupCache(self, dir, filePrefix, fileSuffix, ...
                dataSelection)
            self.cache = containers.Map('KeyType', 'double', ...
                'ValueType', 'any');
            minFile = 1000 * floor(min(dataSelection) / 1000) + 1;
            maxFile = 1000 * ceil(max(dataSelection) / 1000) + 1;
            for fileLower = minFile:1000:maxFile-1000
                fileUpper = fileLower+999;
                filePath = [dir filePrefix num2str(fileLower) '-' ...
                    num2str(fileUpper) fileSuffix];
                features = self.loadFeatures(filePath);
                for id = dataSelection(dataSelection >= fileLower ...
                        & dataSelection <= fileUpper)
                    self.cache(id) = {features(id - fileLower + 1, :)};
                end
            end
        end
        
        function features = loadCaffenet(~, filePath)
            fileID = fopen(filePath, 'r');
            features = fscanf(fileID, '%f', [1000 Inf]);
            fclose(fileID);
        end
        
        function features = loadHmax(~, filePath)
            data = load(filePath);
            features = data.features;
        end
    end
end
