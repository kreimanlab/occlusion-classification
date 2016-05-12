classdef CachingClassifier < Classifier
    % Classifier that lazily caches the features.
    % Whenever features are extracted, the cached features are used if the
    % image hash exists in the cache.
    % If the hash does not exist in the cache, attempts to load the
    % features from the corresponding file.
    % If such a file does not exist, computes the features and saves them
    % in the cache and in a file.
    
    properties
        classifier
        saveFolder
        cache
    end
    
    methods
        function self = CachingClassifier(classifier)
            self.classifier = classifier;
            self.setupSaveFolder();
            self.cache = containers.Map();
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
        
        function features = extractFeatures(self, images, runType)
            boxedFeatures = cell(length(images), 1);
            for i = 1:length(images)
                boxedFeatures{i} = self.getImageFeatures(images{i}, ...
                    runType);
            end
            features = cell2mat(boxedFeatures);
        end
    end
    
    methods (Access=private)
        function boxedFeatures = getImageFeatures(self, image, runType)
            imageHash = hashImage(image);
            % retrieve from cache
            if isKey(self.cache, imageHash)
                boxedFeatures = self.cache(imageHash);
            else
                featuresSaveFile = [self.saveFolder '/' imageHash '.mat'];
                % retrieve from file
                if exist(featuresSaveFile, 'file')
                    loadedData = load(featuresSaveFile);
                    boxedFeatures = loadedData.features(1, :);
                    self.cache(imageHash) = boxedFeatures;
                else % compute from scratch
                    features = self.classifier.extractFeatures({image}, ...
                        runType);
                    boxedFeatures = features(1, :);
                    self.cache(imageHash) = boxedFeatures;
                    save(featuresSaveFile, 'features');
                end
            end
        end
        
        function setupSaveFolder(self)
            self.saveFolder = ['./data/' self.classifier.getName() ...
                '/features-cache'];
            
            if ~exist(self.saveFolder, 'dir')
                mkdir(self.saveFolder);
            end
        end
    end
end
