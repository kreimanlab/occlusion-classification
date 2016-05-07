function [results] = runClassifier(classifier, ...
    trainImages, trainLabels, ...
    testImages, testLabels)
addpath('./data');

USE_SAVED_TRAIN_FEATURES = false;
USE_SAVED_TEST_FEATURES = false;
USE_SAVED_PREDICTION = false;

if nargin < 1
    classifier = HmaxClassifier();
    [trainImages, trainLabels] = getExperimentalData();
    testImages = trainImages;
    testLabels = trainLabels;
end

mkdir(['./data/' classifier.getName()]);

%% Train
% extract features
trainFeaturesSaveFile = ['./data/' classifier.getName() '/train-features.mat'];
if USE_SAVED_TRAIN_FEATURES
    savedOutput = load(trainFeaturesSaveFile);
    trainFeatures = savedOutput.c2;
else
    trainFeatures = classifier.extractFeatures(trainImages);
    save(trainFeaturesSaveFile, 'trainFeatures');
end
% fit
classifier.fit(trainFeatures, trainLabels);

%% Test
% predict
testFeaturesSaveFile = ['./data/' classifier.getName() '/test-features.mat'];
if USE_SAVED_TEST_FEATURES
    load(testFeaturesSaveFile);
else
    testFeatures = classifier.extractFeatures(testImages);
    save(testFeaturesSaveFile, 'testFeatures');
end
predictionsSaveFile = ['./data/' classifier.getName() '/predictions.mat'];
if USE_SAVED_PREDICTION
    load(predictionsSaveFile);
else
    predictedLabels = classifier.predict(testFeatures);
    save(predictionsSaveFile, 'predictedLabels');
end
% analyze
resultsSaveFile = ['./data/' classifier.getName() '/results.mat'];
results = analyzeResults(predictedLabels, testLabels);
save(resultsSaveFile, 'results');
