function [results] = runClassifier(classifier, ...
    trainImages, trainLabels, ...
    testImages, testLabels)
addpath('./data');

if nargin < 1
    classifier = HmaxClassifier();
    [trainImages, trainLabels] = getExperimentalData();
    testImages = trainImages;
    testLabels = trainLabels;
end

saveFolder = ['./data/' classifier.getName()];
if ~exist(saveFolder, 'dir')
    mkdir();
end

%% Train
numTrainImages = length(trainImages);
% extract features
trainFeaturesSaveFile = [saveFolder '/train_features-' num2str(numTrainImages) '.mat'];
if exist(trainFeaturesSaveFile, 'file')
    fprintf('Loading saved train features %s\n', trainFeaturesSaveFile)
    load(trainFeaturesSaveFile);
else
    trainFeatures = classifier.extractFeatures(trainImages);
    save(trainFeaturesSaveFile, 'trainFeatures');
end
% fit
classifier.fit(trainFeatures, trainLabels);

%% Test
numTestImages = length(testImages);
% predict
testFeaturesSaveFile = [saveFolder '/test_features-' num2str(numTestImages) '.mat'];
if exist(testFeaturesSaveFile, 'file')
    fprintf('Loading saved test features %s\n', testFeaturesSaveFile);
    load(testFeaturesSaveFile);
else
    testFeatures = classifier.extractFeatures(testImages);
    save(testFeaturesSaveFile, 'testFeatures');
end
predictionsSaveFile = [saveFolder '/predictions-' num2str(numTestImages) '.mat'];
if exist(predictionsSaveFile, 'file')
    fprintf('Loading saved predictions %s\n', predictionsSaveFile);
    load(predictionsSaveFile);
else
    predictedLabels = classifier.predict(testFeatures);
    save(predictionsSaveFile, 'predictedLabels');
end
% analyze
resultsSaveFile = [saveFolder '/results-' num2str(numTestImages) '.mat'];
results = analyzeResults(predictedLabels, testLabels);
save(resultsSaveFile, 'results');
