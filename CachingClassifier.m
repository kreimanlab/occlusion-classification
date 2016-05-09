classdef CachingClassifier < Classifier
    % Classifier that pre-caches the features.
    % Also creates a cache file for every single image individually
    % so that subsequent calls do not have to re-compute
    % the features for that images.
    
    properties
        classifier
        saveFolder
        cache
    end
    
    methods
        function self = CachingClassifier(images, classifier)
            self.classifier = classifier;
            self.setupSaveFolder();
            self.setupCache(images);
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
        
        function features = extractFeatures(self, images)
            boxedFeatures = cell(length(images), 1);
            for i = 1:length(images)
                boxedFeatures{i} = self.cache(self.hashImage(images{i}));
            end
            features = cell2mat(boxedFeatures);
        end
    end
    
    methods (Access=private)        
        function setupCache(self, images)
            % map expects 1-by-n array
            boxedFeatures = cell(1, length(images));
            hashes = cell(1, length(images));
            for i = 1:length(images)
                features = self.loadOrExtractFeatures(images{i});
                boxedFeatures{i} = features(1, :);
                hashes{i} = self.hashImage(images{i});
            end
            self.cache = containers.Map(hashes, boxedFeatures);
        end
        
        function features = loadOrExtractFeatures(self, image)
            featuresSaveFile = [self.saveFolder '/' ...
                self.hashImage(image) '.mat'];
            if exist(featuresSaveFile, 'file')
                loadedData = load(featuresSaveFile);
                features = loadedData.features;
            else
                features = self.classifier.extractFeatures({image});
                save(featuresSaveFile, 'features');
            end
        end
        
        function setupSaveFolder(self)
            self.saveFolder = ['./data/' self.classifier.getName() ...
                '/features-cache'];
           
            if ~exist(self.saveFolder, 'dir')
                mkdir(self.saveFolder);
            end 
        end
        
        function hash = hashImage(~, image)
            hash = GetMD5(image, 'Array');
        end
    end
end
