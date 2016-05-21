function computeFeatures(varargin)

%% Parameters
argParser = inputParser();
argParser.KeepUnmatched = true;
argParser.addOptional('hopSize', 1000, @isnumeric);
argParser.parse(varargin{:});
hopSize = argParser.Results.hopSize;
fprintf('Running with args (hopSize=%d)\n', hopSize);

addpath(genpath(pwd));

%% Setup
featuresDir = 'data/OcclusionModeling/features';
wholeDir = [featuresDir '/klab325_orig'];
occlusionDir = [featuresDir '/data_occlusion_klab325v2'];
% data
dataset = load('data/data_occlusion_klab325v2.mat');
dataset = dataset.data;
dataset.occluded = []; % delete unneeded columns to free up space
dataset.scramble = []; dataset.pres_time = []; dataset.reaction_times = [];
dataset.responses = []; dataset.correct = []; dataset.VBLsoa = [];
dataset.masked = []; dataset.subject = []; dataset.strong = [];
% classifiers
featureProvider = curry(@FeatureProvider, dataset, 1:length(dataset));
hop = curry(@HopFeatures, hopSize);
featureExtractors = {...
    hop(0, ImageProvider(dataset, PixelFeatures())), ...
    hop(0.8, featureProvider(HmaxFeatures())), ...
    hop(0, featureProvider(AlexnetPool5FeaturesKlabData())), ...
    hop(0, featureProvider(AlexnetFc7FeaturesKlabData()))
    };

%% Run
[~, uniquePresRows] = unique(dataset, 'pres');
for featureExtractorIter = 1:length(featureExtractors)
    featureExtractor = featureExtractors{featureExtractorIter};
    % whole
    fprintf('%s whole images\n', featureExtractor.getName());
    features = featureExtractor.extractFeatures(uniquePresRows, RunType.Train);
    saveFeatures(features, wholeDir, featureExtractor, 1, 325);
    
    % occluded
    for dataIter = 1:1000:length(dataset)
        fprintf('%s occluded %d/%d\n', featureExtractor.getName(), ...
            dataIter, length(dataset));
        dataEnd = dataIter + 999;
        features = featureExtractor.extractFeatures(dataIter:dataEnd, ...
            RunType.Test);
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
