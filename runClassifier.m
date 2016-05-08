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
numTrainImages = length(trainImages);
% extract features
trainFeaturesSaveFile = [saveFolder '/train_features-' ...
    GetMD5(trainImages, 'Array') '.mat'];
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
fprintf('Testing %s...\n', classifier.getName());
numTestImages = length(testImages);
% predict
testFeaturesSaveFile = [saveFolder '/test_features-' ...
    GetMD5(testImages, 'Array') '.mat'];
if exist(testFeaturesSaveFile, 'file')
    fprintf('Loading saved test features %s\n', testFeaturesSaveFile);
    load(testFeaturesSaveFile);
else
    testFeatures = classifier.extractFeatures(testImages);
    save(testFeaturesSaveFile, 'testFeatures');
end
predictionsSaveFile = [saveFolder '/predictions-' ...
    GetMD5(testImages, 'Array') '.mat'];
if exist(predictionsSaveFile, 'file')
    fprintf('Loading saved predictions %s\n', predictionsSaveFile);
    load(predictionsSaveFile);
else
    predictedLabels = classifier.predict(testFeatures);
    save(predictionsSaveFile, 'predictedLabels');
end
% analyze
resultsSaveFile = [saveFolder '/results-' ...
    GetMD5(testImages, 'Array') '.mat'];
[matched, accuracy] = analyzeResults(predictedLabels, testLabels);
results = struct('name', classifier.getName(), ...
    'predicted', predictedLabels, 'real', testLabels,...
    'matched', matched, 'accuracy', accuracy);
save(resultsSaveFile, 'results');
