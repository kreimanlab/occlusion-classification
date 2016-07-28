function runClassification(dataset, varargin)
assert(exist('dataset', 'var') == 1, 'dataset not provided');
%% Parameters
argParser = inputParser();
argParser.KeepUnmatched = true;
argParser.addParameter('dataPath', fileparts(mfilename('fullpath')), ...
    @(p) exist(p, 'dir'));
argParser.addParameter('dataSelection', 1:size(dataset, 1), @isnumeric);
argParser.addParameter('kfold', 5, @isnumeric);
argParser.addParameter('excludeCategories', [], @isnumeric);
argParser.addParameter('featureExtractors', {}, ...
    @(fs) iscell(fs) && all(cellfun(@(f) isa(f, 'FeatureExtractor'), fs)));
argParser.addParameter('classifier', @LibsvmClassifierCCV, ...
    @(c) isa(c, 'function_handle'));

argParser.parse(varargin{:});
dataPath = argParser.Results.dataPath;
dataSelection = argParser.Results.dataSelection;
kfold = argParser.Results.kfold;
excludedCategories = argParser.Results.excludeCategories;
featureExtractors = argParser.Results.featureExtractors;
assert(~isempty(featureExtractors), 'featureExtractors must not be empty');
classifierConstructor = argParser.Results.classifier;

%% Setup
% classifiers
classifiers = cellfun(@(featureExtractor) ...
    classifierConstructor(featureExtractor), ...
    featureExtractors, 'UniformOutput', false);
assert(all(cellfun(@(c) isa(c, 'Classifier'), classifiers)), ...
    'classifier must be of type ''Classifier''');
% data
dataSelection = dataSelection(...
    ~ismember(dataset.truth(dataSelection), excludedCategories));
objectPres = unique(dataset.pres(dataSelection));
% cross validation
rng(1, 'twister'); % seed, use pseudo random generator for reproducibility

%% Run
evaluateClassifiers = curry(@evaluate, dataset, dataSelection, ...
    classifiers);
% parallelPoolObject = parpool; % init parallel computing pool
% crossValStream = RandStream('mlfg6331_64');
% reset(crossValStream);
results = crossval(evaluateClassifiers, objectPres, 'kfold', kfold);%, ...
%     'Options', statset('UseParallel', true, ...
%     'Streams', crossValStream, 'UseSubstreams', true));
% delete(parallelPoolObject); % teardown pool
resultsFile = [dataPath, '/results/' ...
    datestr(datetime(), 'yyyy-mm-dd_HH-MM-SS') '.mat'];
save(resultsFile, 'results');
fprintf('Results stored in ''%s''\n', resultsFile);
end
