function runClassification(varargin)

%% Parameters
argParser = inputParser();
argParser.KeepUnmatched = true;
argParser.addOptional('dataMin', 1, @isnumeric);
argParser.addOptional('dataMax', 13000, @isnumeric);
argParser.addOptional('kfold', 5, @isnumeric);
argParser.addOptional('hopSize', 1000, @isnumeric);
argParser.parse(varargin{:});
dataMin = argParser.Results.dataMin;
dataMax = argParser.Results.dataMax;
kfold = argParser.Results.kfold;
hopSize = argParser.Results.hopSize;
fprintf(['Running with args (dataMin=%d, dataMax=%d, hopSize=%d, '...
    'kfold=%d)\n'], ...
    dataMin, dataMax, hopSize, kfold);

addpath(genpath(pwd));

%% Setup
% data
dataset = load('data_occlusion_klab325v2.mat');
dataset = dataset.data;
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
% cross validation
rng(1, 'twister'); % seed, use pseudo random generator for reproducibility

%% Run
evaluateClassifiers = curry(@evaluate, dataset, classifiers);
results = crossval(evaluateClassifiers, wholeImagePres, 'kfold', kfold)';
resultsFile = ['data/results-classification/' ...
    datestr(datetime(), 'yyyy-mm-dd_HH-MM-SS') '.mat'];
save(resultsFile, 'results');
fprintf('Results stored in ''%s''\n', resultsFile);
end
