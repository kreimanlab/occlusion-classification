function run(varargin)

%% Parameters
argParser = inputParser();
argParser.KeepUnmatched = true;
argParser.addRequired('task', @isstr); % classification / identification
argParser.addOptional('dataMin', 1, @isnumeric);
argParser.addOptional('dataMax', 13000, @isnumeric);
argParser.addOptional('kfold', 5, @isnumeric);
argParser.addOptional('hopSize', 1000, @isnumeric);
argParser.parse(varargin{:});
task = argParser.Results.task;
dataMin = argParser.Results.dataMin;
dataMax = argParser.Results.dataMax;
kfold = argParser.Results.kfold;
hopSize = argParser.Results.hopSize;
switch task
    case 'classification'
        getLabels = @(dataset, rows) dataset.truth(rows);
    case 'identification'
        getLabels = @(dataset, rows) dataset.pres(rows);
    otherwise
        error(['Unknown task ' task]);
end
fprintf(['Running %s with args '...
    '(dataMin=%d, dataMax=%d, hopSize=%d, kfold=%d)\n'], ...
    task, dataMin, dataMax, hopSize, kfold);

addpath(genpath(pwd));

%% Setup
% data
dataset = load('data_occlusion_klab325v2.mat');
dataset = dataset.data;
dataSelection = dataMin:dataMax;
dataset = dataset(dataSelection, :);
wholeImagePres = unique(dataset.pres(:));
% feature extractors + classifier
featureProviderFactory = FeatureProviderFactory(dataset, dataSelection);
hop = curry(@HopFeatures, hopSize);
featureExtractors = {...
    ImageProvider(dataset, PixelFeatures()); ...
    featureProviderFactory.get(HmaxFeatures()); ...
    featureProviderFactory.get(AlexnetPool5FeaturesKlabData()); ...
    featureProviderFactory.get(AlexnetFc7FeaturesKlabData()); ...
    hop(BipolarFeatures(0.01, featureProviderFactory.get(HmaxFeatures()))); ...
    hop(BipolarFeatures(0, featureProviderFactory.get(AlexnetPool5FeaturesKlabData()))); ...
    hop(BipolarFeatures(0, featureProviderFactory.get(AlexnetFc7FeaturesKlabData()))); ...
    RnnFeatureProvider(dataset, RnnFeatures())...
    };
classifiers = cellfun(@(featureExtractor) EcocSvmClassifier(featureExtractor), ...
    featureExtractors, 'UniformOutput', false);
% cross validation
rng(1, 'twister'); % seed, use pseudo random generator for reproducibility

%% Run
evaluateClassifiers = curry(@evaluate, task, dataset, classifiers, getLabels);
parallelPoolObject = parpool; % init parallel computing pool
crossValStream = RandStream('mlfg6331_64');
reset(crossValStream);
results = crossval(evaluateClassifiers, wholeImagePres, 'kfold', kfold, ...
    'Options', statset('UseParallel', true, ...
    'Streams', crossValStream, 'UseSubstreams', true));
delete(parallelPoolObject); % teardown pool
resultsFile = ['data/results-' task '/' ...
    datestr(datetime(), 'yyyy-mm-dd_HH-MM-SS') '.mat'];
save(resultsFile, 'results');
fprintf('Results stored in ''%s''\n', resultsFile);
end
