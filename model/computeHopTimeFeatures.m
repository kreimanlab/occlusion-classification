function computeHopTimeFeatures(dataset, varargin)

%% Setup
argParser = inputParser();
argParser.KeepUnmatched = true;
argParser.addParameter('savesteps', [1:100, 110:10:300], @isnumeric);
argParser.addParameter('trainDirectory', [], @(p) exist(p, 'dir'));
argParser.addParameter('testDirectory', [], @(p) exist(p, 'dir'));

argParser.parse(varargin{:});
fprintf('Computing features in %s with args:\n', pwd);
disp(argParser.Results);
savesteps = argParser.Results.savesteps;
trainDir = argParser.Results.trainDirectory;
testDir = argParser.Results.testDirectory;

% classifiers
featureProviderFactory = FeatureProviderFactory(trainDir, testDir, ...
    dataset.pres, 1:length(dataset));
featureExtractor = HopFeatures(max(savesteps), ...
    BipolarFeatures(0, ...
    featureProviderFactory.get(AlexnetFc7Features())));

%% Run
% whole = fc7. just train hop network on whole.
[~, wholePresRows] = unique(dataset, 'pres');
fprintf('Training on %d whole objects\n', numel(wholePresRows));
features = featureExtractor.extractFeatures(wholePresRows, ...
    RunType.Train, dataset.truth(wholePresRows));
for t = savesteps
    saveFeatures(features, trainDir, ...
        featureExtractor, t, 1, 325);
end
% occluded
for dataIter = 1:1000:length(dataset)
    fprintf('%s occluded %d/%d\n', featureExtractor.getName(), ...
        dataIter, length(dataset));
    dataEnd = dataIter + 999;
    rows = dataIter:dataEnd;
    [~, ys] = featureExtractor.extractFeatures(rows, ...
        RunType.Test, dataset.truth(rows));
    for t = savesteps
        features = ys(:, :, t);
        assert(size(features, 1) == dataEnd - dataIter + 1);
        saveFeatures(features, testDir, ...
            featureExtractor, t, dataIter, dataEnd);
    end
end
end

function saveFeatures(features, dir, classifier, timestep, ...
    dataMin, dataMax)
save([dir '/' ...
    regexprep(classifier.getName(), '_t[0-9]+', ['_t' num2str(timestep)])...
    '_' num2str(dataMin) '-' num2str(dataMax) '.mat'], ...
    '-v7.3', 'features');
end
