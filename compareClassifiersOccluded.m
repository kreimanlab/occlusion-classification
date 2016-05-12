function compareClassifiersOccluded(dataMin, dataMax)
if nargin < 1
    dataMin = 1; dataMax = 1000;
else
    dataMin = str2num(dataMin); dataMax = str2num(dataMax);
end

addpath('./data');
addpath('./pixel');
addpath('./hmax');
addpath('./alexnet');
addpath('./visualize');
addpath(genpath('./helper'));

%% Setup
% data
dataset = load('data_occlusion_klab325v2.mat');
dataset = dataset.data;
dataSelection = dataMin:dataMax;
data = dataset(dataSelection, :);
% classifiers
featureProvidingConstructor = curry(@FeatureProvidingClassifier, ...
    data, dataSelection);
classifiers = {ImageProvidingClassifier(data, PixelClassifier()), ...
    featureProvidingConstructor(HmaxClassifier()), ...
    featureProvidingConstructor(AlexnetPool5ClassifierKlabData()), ...
    featureProvidingConstructor(AlexnetFc7ClassifierKlabData())};
% cross validation
rng(1, 'twister'); % seed, use pseudo random generator for reproducibility

%% Run
% evaluate a classifier given training and test data
    function results = evaluate(classifiers, ...
            xtrain, ytrain, xtest, ytest)
        results = cell(length(classifiers), 1);
        for iClassifier = 1:length(classifiers)
            results{iClassifier} = runClassifier(...
                classifiers{iClassifier}, xtrain, ytrain, xtest, ytest);
        end
    end
kfold = 2;
stepSize = 15;
percentsVisible = 0:stepSize:35;
results = repmat(struct('name', [], 'predicted', [], 'real', [], ...
    'matched', [], 'accuracy', []), ... % need to pre-allocate array
    length(percentsVisible), length(classifiers), kfold);
for iPv = 1:length(percentsVisible)
    fprintf('%d percent visibility\n', percentsVisible(iPv));
    percentBlack = 100 - percentsVisible(iPv);
    dataSelectionSubset = dataSelection(...
        data.black > percentBlack - stepSize / 2 & ...
        data.black <= percentBlack + stepSize / 2);
    runner = curry(@evaluate, classifiers);
    classifierResults = crossval(runner, ...
        dataSelectionSubset', data.truth(dataSelectionSubset), ...
        'kfold', kfold)';
    results(iPv, :, :) = cell2mat(classifierResults);
end
save(['data/compareOccluded/' ...
    datestr(datetime(), 'yyyy-mm-dd_HH-MM-SS') '.mat'], ...
    'percentsVisible', 'results');

%% display
displayResults(percentsVisible, results);
end
