function runIdentification(varargin)

%% Parameters
argParser = inputParser();
argParser.KeepUnmatched = true;
argParser.addOptional('dataMin', 1, @isnumeric);
argParser.addOptional('dataMax', 1000, @isnumeric);
argParser.addOptional('hopSize', 1000, @isnumeric);
argParser.parse(varargin{:});
dataMin = argParser.Results.dataMin;
dataMax = argParser.Results.dataMax;
hopSize = argParser.Results.hopSize;
fprintf(['Running with args (dataMin=%d, dataMax=%d, hopSize=%d)\n'], ...
    dataMin, dataMax, hopSize);

addpath(genpath(pwd));

%% Setup
% data
dataset = load('data_occlusion_klab325v2.mat');
dataset = dataset.data;
dataSelection = dataMin:dataMax;
dataset = dataset(dataSelection, :);
% feature extractors + classifier
featureProvider = curry(@FeatureProvider, dataset, dataSelection);
hop = curry(@HopFeatures, hopSize);
featureExtractors = {...
%     ImageProvider(dataset, PixelFeatures()), ...
%     featureProvider(HmaxFeatures()), ...
    featureProvider(AlexnetPool5FeaturesKlabData()), ...
    featureProvider(AlexnetFc7FeaturesKlabData()), ...
%     hop(BipolarFeatures(0.01, featureProvider(HmaxFeatures()))), ...
%     hop(BipolarFeatures(0, featureProvider(AlexnetPool5FeaturesKlabData()))), ...
%     hop(BipolarFeatures(0, featureProvider(AlexnetFc7FeaturesKlabData()))), ...
%     RnnFeatureProvider(dataset, RnnFeatures())...
    };
classifiers = cellfun(@(featureExtractor) ...
    SvmClassifier(featureExtractor), ...
    featureExtractors, 'UniformOutput', false);
% cross validation
rng(1, 'twister'); % seed, use pseudo random generator for reproducibility

%% Run
[~, trainX] = unique(dataset.pres(:));
trainY = dataset.pres(trainX);
for iClassifier = 1:length(classifiers)
    classifier = classifiers{iClassifier};
    fprintf('Training %s on all whole images...\n', classifier.getName());
    classifier.train(trainX, trainY);
    fprintf('Testing %s on all occluded images...\n', ...
        classifier.getName());
    testX = dataSelection;
    testY = dataset.pres(testX);
    predictedY = classifier.predict(testX);
    
    correct = analyzeResults(predictedY, testY);
    currentResults = struct2dataset(struct(...
        'name', {repmat({classifier.getName()}, length(testX), 1)}, ...
        'pres', dataset.pres(testX), ...
        'response', predictedY, 'truth', testY,...
        'correct', correct, 'black', dataset.black(testX)));
    if ~exist('results', 'var')
        results = currentResults;
    else
        results = [results; currentResults];
    end
end
resultsFile = ['data/results-identification/' ...
    datestr(datetime(), 'yyyy-mm-dd_HH-MM-SS') '.mat'];
save(resultsFile, 'results');
fprintf('Results stored in ''%s''\n', resultsFile);
