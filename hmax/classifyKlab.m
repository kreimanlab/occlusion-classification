function [matched] = classifyKlab()
addpath('../data');
addpath('..');

USE_SAVED_C2 = true;
USE_SAVED_C2TEST = true;
USE_SAVED_PREDICTION = true;

%% Train
% Run HMAX on training images
[images, labels] = getExperimentalData();
if USE_SAVED_C2
    savedOutput = load('./training_output/activations.mat');
    c2Train = savedOutput.c2;
else
    c2Train = runHmax(images, './training_output/');
end

% prepare input (c2)
c2TrainBandsPool = poolC2(c2Train);
assert(length(labels) == size(c2TrainBandsPool,1));
% prepare input (c1)
%     c1_bands_pool = cell(size(c1))
%     for i=1:length(c1_bands_pool)
%         c1_bands_pool{1,i} = zeros(size(c1{1,i}{1,1}));
%         c1_bands_pool{1,i}(:) = max(c1{1,i}{:});
%     end

% fit
classifier = fitcecoc(c2TrainBandsPool,labels);

%% Test
testImages = images;
realLabels = labels;
% predict
savedC2TestFile = './testing_output/activations.mat';
if USE_SAVED_C2TEST
    load(savedC2TestFile);
else
    c2Test = runHmax(testImages,'./testing_output/');
end
savedPredictionsFile = './testing_output/predictions.mat';
if USE_SAVED_PREDICTION
    load(savedPredictionsFile);
else
    c2TestBandsPool = poolC2(c2Test);
    predictedLabels = classifier.predict(c2TestBandsPool);
    save(savedPredictionsFile, 'c2TestBandsPool', 'predictedLabels');
end
% analyze
matched = analyzeResults(predictedLabels, realLabels);
