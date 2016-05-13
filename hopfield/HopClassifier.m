classdef HopClassifier < Classifier
    % Classifier extension that attracts features to previously learned
    % ones.
    % Utilizes a Hopfield attractor network.
    
    properties
        classifier
        net
        threshold = 0
        steps = 10
    end
    
    methods
        function obj = HopClassifier(downsampledLength, classifier)
            obj.downsampledLength = downsampledLength;
            obj.classifier = classifier;
        end
        
        function name = getName(self)
            name = [self.classifier.getName() '-hop'];
        end
        
        function features = extractFeatures(self, images, runType)
            T = self.classifier.extractFeatures(images, runType);
            T = self.downsample(T);
            T(T > self.threshold) = 1;
            T(T == self.threshold) = -1;
            features = T;
        end
        
        function fit(self, features, labels)
            T = features';
            self.net = newhop(T);
            self.classifier.fit(T', labels);
        end
        
        function labels = predict(self, features)
            labels = zeros(size(features, 1), 1);
            for i = 1:size(features, 1)
                y = self.net({1 self.steps}, {}, {features(i, :)'});
                T = y{self.steps};
                labels(i) = self.classifier.predict(T');
            end
        end
    end
    
    methods(Access = private)
        function downsampledFeatures = downsample(self, features)
            downsampledFeatures = zeros(size(features, 1), ...
                self.downsampledLength);
            sampleSteps = ceil(size(features, 2) / self.downsampledLength);
            for i = 1:size(features, 1)
                downsampledFeatures(i, :) = downsample(features(i, :), ...
                    sampleSteps);
            end
        end
    end
end

