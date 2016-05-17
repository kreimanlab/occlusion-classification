function computeFeatures(varargin)

%% Parameters
argParser = inputParser();
argParser.KeepUnmatched = true;
argParser.addOptional('hopSize', 1000, @isnumeric);
argParser.parse(varargin{:});
hopSize = argParser.Results.hopSize;
fprintf('Running with args (hopSize=%d)\n', hopSize);

addpath('./data');
addpath('./pixel');
addpath('./hmax');
addpath('./alexnet');
addpath('./hopfield');
addpath('./visualize');
addpath(genpath('./helper'));

%% Setup
featuresDir = 'data/OcclusionModeling/features';
wholeDir = [featuresDir '/klab325_orig'];
occlusionDir = [featuresDir '/data_occlusion_klab325v2'];
% data
dataset = load('data_occlusion_klab325v2.mat');
dataset = dataset.data;
dataset.occluded = []; % delete unneeded columns to free up space
dataset.scramble = []; dataset.pres_time = []; dataset.reaction_times = [];
dataset.responses = []; dataset.correct = []; dataset.VBLsoa = [];
dataset.masked = []; dataset.subject = []; dataset.strong = [];
% classifiers
featureProvidingConstructor = curry(@FeatureProvidingClassifier, ...
    dataset, 1:length(dataset));
hopConstructor = curry(@HopClassifier, hopSize);
classifiers = {ImageProvidingClassifier(dataset, PixelClassifier()), ...
    featureProvidingConstructor(HmaxClassifier()), ...
    featureProvidingConstructor(AlexnetPool5ClassifierKlabData()), ...
    featureProvidingConstructor(AlexnetFc7ClassifierKlabData())
    };
classifiers = cellfun(@(c) hopConstructor(c), classifiers, ...
    'UniformOutput', false);

%% Run
[~, uniquePresRows] = unique(dataset, 'pres');
for classifierIter = 1:length(classifiers)
    classifier = classifiers{classifierIter};
    % whole
    features = classifier.extractFeatures(uniquePresRows, RunType.Train);
    saveFeatures(features, wholeDir, classifier, 1, 325);
    
    % occluded
    for dataIter = 1:1000:length(dataset)
        dataEnd = dataIter + 999;
        features = classifier.extractFeatures(dataIter:dataEnd, ...
            RunType.Test);
        saveFeatures(features, occlusionDir, classifier, dataIter, dataEnd);
    end
end
end

function saveFeatures(features, dir, classifier, dataMin, dataMax)
actualHopSize = size(features, 2);
save([dir '/' classifier.getName() num2str(actualHopSize) '_' ...
    num2str(dataMin) '-' num2str(dataMax) '.mat'], ...
    '-v7.3', 'features');
end
