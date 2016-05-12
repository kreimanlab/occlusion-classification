function results = runClassifier(classifier, ...
    trainImages, trainLabels, ...
    testImages, testLabels)

if nargin < 5
    error('not enough arguments');
end

%% Train
fprintf('Training %s...\n', classifier.getName());
% extract features
trainFeatures = classifier.extractFeatures(trainImages, RunType.Train);
% fit
classifier.fit(trainFeatures, trainLabels);

%% Test
fprintf('Testing %s...\n', classifier.getName());
% predict
testFeatures = classifier.extractFeatures(testImages, RunType.Test);
predictedLabels = classifier.predict(testFeatures);
% analyze
[matched, accuracy] = analyzeResults(predictedLabels, testLabels);
results = struct('name', classifier.getName(), ...
    'predicted', predictedLabels, 'real', testLabels,...
    'matched', matched, 'accuracy', accuracy);
