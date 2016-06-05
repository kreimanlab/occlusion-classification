function computeHopTimeFeatures()
addpath(genpath(pwd));

savesteps = [1:20, 30:10:100, 200:100:1000];

%% Setup
featuresDir = 'data/features';
wholeDir = [featuresDir '/klab325_orig'];
occlusionDir = [featuresDir '/data_occlusion_klab325v2'];
% data
dataset = load('data/data_occlusion_klab325v2.mat');
dataset = dataset.data;
% classifiers
featureProvider = curry(@FeatureProvider, dataset, 1:length(dataset));
featureExtractor = HopFeatures(max(savesteps), ...
    BipolarFeatures(0, ...
    featureProvider(AlexnetFc7Features())));

%% Run
% whole = fc7. just train hop network on whole.
[~, wholePresRows] = unique(dataset, 'pres');
fprintf('Training on %d whole objects\n', numel(wholePresRows));
features = featureExtractor.extractFeatures(wholePresRows, RunType.Train, []);
for t = savesteps
    saveFeatures(features, wholeDir, ...
        featureExtractor, t, 1, 325);
end
% occluded
for dataIter = 1:1000:length(dataset)
    fprintf('%s occluded %d/%d\n', featureExtractor.getName(), ...
        dataIter, length(dataset));
    dataEnd = dataIter + 999;
    [~, y] = featureExtractor.extractFeatures(dataIter:dataEnd, ...
        RunType.Test, []);
    for t = savesteps
        saveFeatures(y{t}, occlusionDir, ...
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
