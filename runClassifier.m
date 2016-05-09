function results = runClassifier(classifier, ...
    trainImages, trainLabels, ...
    testImages, testLabels)

if nargin < 5
    error('not enough arguments');
end

saveFolder = ['./data/' classifier.getName()];
if ~exist(saveFolder, 'dir')
    mkdir(saveFolder);
end

%% Train
fprintf('Training %s...\n', classifier.getName());
% extract features
trainFeatures = classifier.extractFeatures(trainImages);
% fit
classifier.fit(trainFeatures, trainLabels);

%% Test
fprintf('Testing %s...\n', classifier.getName());
% predict
testFeatures = classifier.extractFeatures(testImages);
predictedLabels = classifier.predict(testFeatures);
% analyze
resultsSaveFile = [saveFolder '/results-' ...
    GetMD5(testImages, 'Array') '.mat'];
[matched, accuracy] = analyzeResults(predictedLabels, testLabels);
results = struct('name', classifier.getName(), ...
    'predicted', predictedLabels, 'real', testLabels,...
    'matched', matched, 'accuracy', accuracy);
save(resultsSaveFile, 'results');
