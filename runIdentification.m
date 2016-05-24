function runIdentification(varargin)

%% Parameters
argParser = inputParser();
argParser.KeepUnmatched = true;
argParser.addOptional('dataMin', 1, @isnumeric);
argParser.addOptional('dataMax', 1000, @isnumeric);
argParser.addOptional('visibilityStepSize', 15, @isnumeric);
argParser.addOptional('hopSize', 1000, @isnumeric);
argParser.parse(varargin{:});
dataMin = argParser.Results.dataMin;
dataMax = argParser.Results.dataMax;
visibilityStepSize = argParser.Results.visibilityStepSize;
hopSize = argParser.Results.hopSize;
fprintf(['Running with args (dataMin=%d, dataMax=%d, hopSize=%d, '...
    'visibilityStepSize=%d)\n'], ...
    dataMin, dataMax, hopSize, visibilityStepSize);

addpath(genpath(pwd));

%% Setup
% data
dataset = load('data_occlusion_klab325v2.mat');
dataset = dataset.data(dataset.data.pres <= 300, :);
dataSelection = dataMin:dataMax;
dataset = dataset(dataSelection, :);
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
classifiers = cellfun(@(featureExtractor) ...
    SvmClassifier(featureExtractor), ...
    featureExtractors, 'UniformOutput', false);
% cross validation
rng(1, 'twister'); % seed, use pseudo random generator for reproducibility

%% Run
percentsVisible = 0:visibilityStepSize:35;
[~, trainX] = unique(dataset.pres(:));
trainY = dataset.pres(trainX);
results = repmat(struct('name', [], 'predicted', [], 'real', [], ...
    'matched', [], 'accuracy', []), ...
    length(percentsVisible), length(classifiers)); % pre-allocate
for iClassifier = 1:length(classifiers)
    classifier = classifiers{iClassifier};
    fprintf('Training %s...\n', classifier.getName());
    classifier.train(trainX, trainY);
    for iPv = 1:length(percentsVisible)
        fprintf('Testing %s on %d percent visibility...\n', ...
            classifier.getName(), percentsVisible(iPv));
        percentBlack = 100 - percentsVisible(iPv);
        testX = dataSelection(...
            dataset.black >  percentBlack - visibilityStepSize / 2 & ...
            dataset.black <= percentBlack + visibilityStepSize / 2);
        testY = dataset.pres(testX);
        predictedY = classifier.predict(testX);
        
        [matched, accuracy] = analyzeResults(predictedY, testY);
        results(iPv, iClassifier) = struct('name', classifier.getName(), ...
            'predicted', predictedY, 'real', testY,...
            'matched', matched, 'accuracy', accuracy);
    end
end
resultsFile = ['data/results-identification/' ...
    datestr(datetime(), 'yyyy-mm-dd_HH-MM-SS') '.mat'];
save(resultsFile, 'percentsVisible', 'results');
fprintf('Results stored in ''%s''\n', resultsFile);
