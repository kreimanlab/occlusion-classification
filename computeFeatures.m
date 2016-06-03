function computeFeatures(varargin)
addpath(genpath(pwd));

%% Setup
featuresDir = 'data/features';
wholeDir = [featuresDir '/klab325_orig'];
occlusionDir = [featuresDir '/data_occlusion_klab325v2'];
% data
dataset = load('data/data_occlusion_klab325v2.mat');
dataset = dataset.data;
% feature extractors
featureProvider = curry(@FeatureProvider, dataset, 1:length(dataset));
hop = curry(@HopFeatures, 10);
featureExtractors = {...
    hop(BipolarFeatures(126 / 2, ImageProvider(dataset, PixelFeatures()))); ...
    hop(BipolarFeatures(0.01, featureProvider(HmaxFeatures()))); ...
    hop(BipolarFeatures(0, featureProvider(AlexnetPool5Features()))); ...
    hop(BipolarFeatures(0, featureProvider(AlexnetFc7Features()))); ...
    hop(BipolarFeatures(0, featureProvider(AlexnetFc8Features())))
    };

%% Run
[~, uniquePresRows] = unique(dataset, 'pres');
for featureExtractorIter = 1:length(featureExtractors)
    featureExtractor = featureExtractors{featureExtractorIter};
    % whole
    fprintf('%s whole images\n', featureExtractor.getName());
    features = featureExtractor.extractFeatures(uniquePresRows, ...
        RunType.Train, []);
    saveFeatures(features, wholeDir, featureExtractor, 1, 325);
    
    % occluded
    for dataIter = 1:1000:length(dataset)
        fprintf('%s occluded %d/%d\n', featureExtractor.getName(), ...
            dataIter, length(dataset));
        dataEnd = dataIter + 999;
        features = featureExtractor.extractFeatures(dataIter:dataEnd, ...
            RunType.Test, []);
        saveFeatures(features, occlusionDir, ...
            featureExtractor, dataIter, dataEnd);
    end
end
end

function saveFeatures(features, dir, classifier, dataMin, dataMax)
save([dir '/' classifier.getName() '_' ...
    num2str(dataMin) '-' num2str(dataMax) '.mat'], ...
    '-v7.3', 'features');
end
