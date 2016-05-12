function compareClassifiersOccluded(dataMin, dataMax)
if nargin < 1
    dataMin = 1; dataMax = 5000;
end

addpath('./data');
addpath('./pixel');
addpath('./hmax');
addpath('./alexnet');
addpath(genpath('./helper'));

%% Setup
% data
dataset = load('data_occlusion_klab325v2.mat');
dataset = dataset.data;
dataSelection = dataMin:dataMax;
data = dataset(dataSelection, :);
% classifiers
featureProvidingConstructor = curry(@FeatureProvidingClassifier, ...
    dataSelection);
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
stepSize = 5;
percentsVisible = 0:stepSize:35;
results = repmat(struct('name', [], 'predicted', [], 'real', [], ...
    'matched', [], 'accuracy', []), ... % need to pre-allocate array
    length(classifiers), length(percentsVisible), kfold);
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
    results(:, iPv, :) = cell2mat(classifierResults);
end
save(['data/compareOccluded/' ...
    datestr(datetime(), 'yyyy-mm-dd_HH-MM-SS') '.mat'], 'results');

%% display
% reshape to visibility x classifiers x trials
accuracies = 100 * reshape([results.accuracy], ...
    length(percentsVisible), length(classifiers), kfold);
classifierNames = {results(:, 1, 1).name};
figure();
hold on;
xlim([min(percentsVisible)-3, max(percentsVisible)+3]);
ylim([0 100]);
errorbar(permute(repmat(percentsVisible, 4, 1), [2 1]), ...
    mean(accuracies, 3), std(accuracies, 0, 3), 'o-');
plot(get(gca,'xlim'), [20 20], '--k');
xlabel('Percent Visible');
ylabel('Performance');
legend(classifierNames);
hold off;
end
