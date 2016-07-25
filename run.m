function run(varargin)

dataset = load('dataset_extended.mat');
dataset = dataset.data;
%% Parameters
argParser = inputParser();
argParser.KeepUnmatched = true;
argParser.addRequired('task', @isstr);
argParser.addParameter('dataMin', 1, @isnumeric);
argParser.addParameter('dataMax', size(dataset, 1), @isnumeric);
argParser.addParameter('kfold', 5, @isnumeric);
argParser.addParameter('excludeCategories', [], @isnumeric);
argParser.parse(varargin{:});
task = argParser.Results.task;
dataMin = argParser.Results.dataMin;
dataMax = argParser.Results.dataMax;
kfold = argParser.Results.kfold;
excludedCategories = argParser.Results.excludeCategories;
switch task
    case 'classification'
        getLabels = @(dataset, rows) dataset.truth(rows);
    case 'identification'
        getLabels = @(dataset, rows) dataset.pres(rows);
    otherwise
        error(['Unknown task ' task]);
end
fprintf('Running %s in %s with args:\n', task, pwd);
disp(argParser.Results);

%% Setup
% data
dataSelection = dataMin:dataMax;
dataSelection = dataSelection(...
    ~ismember(dataset.truth(dataSelection), excludedCategories));
objectPres = unique(dataset.pres(dataSelection));
% feature extractors + classifier
featureProviderFactory = FeatureProviderFactory(dataset, dataSelection);
hop = curry(@HopFeatures, 10);
featureExtractors = {...
%     ImageProvider(dataset, PixelFeatures()); ...
%     featureProviderFactory.get(HmaxFeatures()); ...
%     featureProviderFactory.get(AlexnetPool5Features()); ...
    featureProviderFactory.get(AlexnetFc7Features()); ...
%     hop(BipolarTrainFeatures(0.01, featureProviderFactory.get(HmaxFeatures()))); ...
%     hop(BipolarTrainFeatures(0, featureProviderFactory.get(AlexnetPool5Features()))); ...
%     hop(BipolarTrainFeatures(0, featureProviderFactory.get(AlexnetFc7Features()))); ...
    RnnFeatureProvider(dataset, RnnFeatures(4, []))...
%     RnnFeatureProvider(dataset, NamedFeatures('RnnFeatures-timestep5'))...
    };
classifiers = cellfun(@(featureExtractor) LibsvmClassifierCCV(featureExtractor), ...
    featureExtractors, 'UniformOutput', false);
% cross validation
rng(1, 'twister'); % seed, use pseudo random generator for reproducibility

%% Run
evaluateClassifiers = curry(@evaluate, task, dataset, dataSelection, ...
    classifiers, getLabels);
% parallelPoolObject = parpool; % init parallel computing pool
% crossValStream = RandStream('mlfg6331_64');
% reset(crossValStream);
results = crossval(evaluateClassifiers, objectPres, 'kfold', kfold);%, ...
%     'Options', statset('UseParallel', true, ...
%     'Streams', crossValStream, 'UseSubstreams', true));
% delete(parallelPoolObject); % teardown pool
resultsFile = ['data/results/' task '/' ...
    datestr(datetime(), 'yyyy-mm-dd_HH-MM-SS') '.mat'];
save(resultsFile, 'results');
fprintf('Results stored in ''%s''\n', resultsFile);
end
