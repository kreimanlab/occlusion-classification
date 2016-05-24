function runClassification(varargin)

%% Parameters
argParser = inputParser();
argParser.KeepUnmatched = true;
argParser.addOptional('dataMin', 1, @isnumeric);
argParser.addOptional('dataMax', 12600, @isnumeric);
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
dataset = dataset.data(dataset.data.pres <= 300, :);
dataSelection = dataMin:dataMax;
dataset = dataset(dataSelection, :);
wholeImagePres = unique(dataset.pres(:));
% feature extractors + classifier
featureProvider = curry(@FeatureProvider, dataset, dataSelection);
hop = curry(@HopFeatures, hopSize);
featureExtractors = {...
    ImageProvider(dataset, PixelFeatures()), ...
    featureProvider(HmaxFeatures()), ...
    featureProvider(AlexnetPool5FeaturesKlabData()), ...
    featureProvider(AlexnetFc7FeaturesKlabData()), ...
    hop(BipolarFeatures(0.01, featureProvider(HmaxFeatures()))), ...
    hop(BipolarFeatures(0, featureProvider(AlexnetPool5FeaturesKlabData()))), ...
    hop(BipolarFeatures(0, featureProvider(AlexnetFc7FeaturesKlabData()))), ...
    RnnFeatureProvider(dataset, RnnFeatures())...
    };
classifiers = cellfun(@(featureExtractor) SvmClassifier(featureExtractor), ...
    featureExtractors, 'UniformOutput', false);
classifiers{end+1} = HumanReplayClassifier(dataset);
% cross validation
rng(1, 'twister'); % seed, use pseudo random generator for reproducibility

%% Run
percentsVisible = 0:visibilityStepSize:35;
visibilityMargin = visibilityStepSize / 2;
evaluateClassifiers = curry(@evaluate, dataset, ...
    percentsVisible, visibilityMargin, classifiers);
results = crossval(evaluateClassifiers, ...
    wholeImagePres, 'kfold', kfold)';
results = cell2mat(reshape(results, [1 1 kfold]));
resultsFile = ['data/results-classification/' ...
    datestr(datetime(), 'yyyy-mm-dd_HH-MM-SS') '.mat'];
save(resultsFile, 'percentsVisible', 'results');
fprintf('Results stored in ''%s''\n', resultsFile);
end
