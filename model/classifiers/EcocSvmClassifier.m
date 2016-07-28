classdef EcocSvmClassifier < Classifier
    %ECOCSVMCLASSIFIER One-vs-one SVM error-correcting-output-codes
    %classifier.
    
    properties
        name = 'ecoc_svm_linear'
        model
    end
    
    methods
        function obj = EcocSvmClassifier(featureExtractor)
            obj@Classifier(featureExtractor);
        end
        
        function fit(self, features, labels)
            template = templateSVM('Standardize', 1, ...
                'KernelFunction', 'linear');
            self.model = fitcecoc(features, labels, ...
                'Learners', template);
        end
        
        function labels = classify(self, features)
            labels = self.model.predict(features);
        end
    end    
end
