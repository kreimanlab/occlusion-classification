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

addpath('./data');
addpath('./pixel');
addpath('./hmax');
addpath('./alexnet');
addpath('./human');
addpath('./hopfield');
addpath('./visualize');
addpath(genpath('./helper'));

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
% classifiers
featureProvidingConstructor = curry(@FeatureProvidingClassifier, ...
    dataset, dataSelection);
hopConstructor = curry(@HopClassifier, hopSize);
classifiers = {ImageProvidingClassifier(dataset, PixelClassifier()), ...
    featureProvidingConstructor(HmaxClassifier()), ...
    featureProvidingConstructor(AlexnetPool5ClassifierKlabData()), ...
    featureProvidingConstructor(AlexnetFc7ClassifierKlabData()), ...
    HumanReplayClassifier(dataset), ...
    featureProvidingConstructor(hopConstructor(0.8, featureProvidingConstructor(HmaxClassifier()))), ...
    featureProvidingConstructor(hopConstructor(0, featureProvidingConstructor(AlexnetPool5ClassifierKlabData()))), ...
    featureProvidingConstructor(hopConstructor(0, featureProvidingConstructor(AlexnetFc7ClassifierKlabData())))...
    };
% cross validation
rng(1, 'twister'); % seed, use pseudo random generator for reproducibility

%% Run
% evaluate a classifier given training and test data
function results = evaluate(classifiers, ...
    xtrain, ytrain, xtest, ytest)
results = cell(length(classifiers), 1);
for iClassifier = 1:length(classifiers)
    results{iClassifier} = runClassifier(...
        classifiers{iClassifier}, xtrain, ytrain, xtest, ytest);
end
end
percentsVisible = 0:visibilityStepSize:35;
results = repmat(struct('name', [], 'predicted', [], 'real', [], ...
    'matched', [], 'accuracy', []), ... % need to pre-allocate array
    length(percentsVisible), length(classifiers), kfold);
for iPv = 1:length(percentsVisible)
    fprintf('%d percent visibility\n', percentsVisible(iPv));
    percentBlack = 100 - percentsVisible(iPv);
    dataSelectionSubset = dataSelection(...
        dataset.black > percentBlack - visibilityStepSize / 2 & ...
        dataset.black <= percentBlack + visibilityStepSize / 2);
    runner = curry(@evaluate, classifiers);
    classifierResults = crossval(runner, ...
        dataSelectionSubset', dataset.truth(dataSelectionSubset), ...
        'kfold', kfold)';
    results(iPv, :, :) = cell2mat(classifierResults);
end
resultsFile = ['data/compareOccluded/' ...
    datestr(datetime(), 'yyyy-mm-dd_HH-MM-SS') '.mat'];
save(resultsFile, 'percentsVisible', 'results');
fprintf('Results stored in ''%s''\n', resultsFile);
end
