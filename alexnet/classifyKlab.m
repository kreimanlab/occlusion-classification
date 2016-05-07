FC7OUTPUT_LENGTH = 4096;

%% Preparation
% Load network parameters.
netParams = load('./ressources/alexnetParams.mat'); % obtained from https://drive.google.com/file/d/0B-VdpVMYRh-pQWV1RWt5NHNQNnc/view

% Load data
addpath('../data');
[images, labels] = getExperimentalData();

%% get output for images
disp 'Computing image activations...'
alexnetOutputs = getImageFc7Outputs(images);

%% train classifier
disp 'Training classifier...'
classifier = fitcecoc(alexnetOutputs,labels);

%% test
disp 'Testing...'
testImage = images{1};
data = prepareGrayscaleImage(testImage);
fc7 = getFc7Output(netParams, data);
predictedLabel = classifier.predict(reshape(fc7, [1 FC7OUTPUT_LENGTH]));
fprintf('Predicted class %d\n', predictedLabel);
