function compareClassifiers(varargin)

%% Parameters
argParser = inputParser();
argParser.KeepUnmatched = true;
argParser.addOptional('dataMin', 1, @isnumeric);
argParser.addOptional('dataMax', 1000, @isnumeric);
argParser.addOptional('kfold', 5, @isnumeric);
argParser.addOptional('visibilityStepSize', 15, @isnumeric);
argParser.addOptional('hopSize', 1000, @isnumeric);
argParser.parse(varargin{:});
dataMin = argParser.Results.dataMin;
dataMax = argParser.Results.dataMax;
kfold = argParser.Results.kfold;
visibilityStepSize = argParser.Results.visibilityStepSize;
hopSize = argParser.Results.hopSize;
fprintf(['Running with args (dataMin=%d, dataMax=%d, hopSize=%d, '...
    'kfold=%d, visibilityStepSize=%d)\n'], ...
    dataMin, dataMax, hopSize, kfold, visibilityStepSize);

addpath(genpath(pwd));

%% Setup
% data
dataset = load('data_occlusion_klab325v2.mat');
dataset = dataset.data;
dataSelection = dataMin:dataMax;
dataset = dataset(dataSelection, :);
dataset.occluded = []; % delete unneeded columns to free up space
dataset.scramble = []; dataset.pres_time = []; dataset.reaction_times = [];
dataset.responses = []; dataset.correct = []; dataset.VBLsoa = [];
dataset.masked = []; dataset.subject = []; dataset.strong = [];
% feature extractors + classifier
featureProvider = curry(@FeatureProvider, dataset, dataSelection);
hop = curry(@HopFeatures, hopSize);
featureExtractors = {...
    ImageProvider(dataset, PixelFeatures()), ...
    featureProvider(HmaxFeatures()), ...
    featureProvider(AlexnetPool5FeaturesKlabData()), ...
    featureProvider(AlexnetFc7FeaturesKlabData()), ...
    featureProvider(hop(0.01, HmaxFeatures())), ...
    featureProvider(hop(0, AlexnetPool5FeaturesKlabData())), ...
    featureProvider(hop(0, AlexnetFc7FeaturesKlabData())),...
    RnnFeatureProvider(dataset, RnnFeatures())...
    };
classifiers = cellfun(@(featureExtractor) SvmClassifier(featureExtractor), ...
    featureExtractors, 'UniformOutput', false);
classifiers{end+1} = HumanReplayClassifier(dataset);
% cross validation
rng(1, 'twister'); % seed, use pseudo random generator for reproducibility

%% Run
percentsVisible = 0:visibilityStepSize:35;
results = repmat(struct('name', [], 'predicted', [], 'real', [], ...
    'matched', [], 'accuracy', []), ... % need to pre-allocate array
    length(percentsVisible), length(classifiers), kfold);
for iPv = 1:length(percentsVisible)
    fprintf('%d percent visibility\n', percentsVisible(iPv));
    percentBlack = 100 - percentsVisible(iPv);
    dataSelectionSubset = dataSelection(...
        dataset.black >  percentBlack - visibilityStepSize / 2 & ...
        dataset.black <= percentBlack + visibilityStepSize / 2);
    labels = dataset.truth(dataSelectionSubset);
    runner = curry(@evaluate, classifiers);
    currentResults = crossval(runner, ...
        dataSelectionSubset', labels, ...
        'kfold', kfold)';
    results(iPv, :, :) = cell2mat(currentResults);
end
resultsFile = ['data/compareOccluded/' ...
    datestr(datetime(), 'yyyy-mm-dd_HH-MM-SS') '.mat'];
save(resultsFile, 'percentsVisible', 'results');
fprintf('Results stored in ''%s''\n', resultsFile);
end
