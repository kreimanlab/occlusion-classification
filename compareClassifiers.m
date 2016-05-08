function compareClassifiers()
addpath('./data');
addpath('./pixel');
addpath('./hmax');
addpath('./alexnet');
addpath(genpath('./helper'));

%% Setup
% classifiers
classifiers = {SvmClassifier()};%, HmaxClassifier(), AlexnetClassifier()};
% data
[images, labels] = getExperimentalData();
% cross validation
rng(1, 'twister'); % seed and use pseudo random generator for reproducibility
% function to retrieve the accuracy from a run result
    function accuracy = runAndGetAccuracy(classifier, xtrain, ytrain, xtest, ytest)
        results = runClassifier(classifier, xtrain, ytrain, xtest, ytest);
        accuracy = results.accuracy;
    end

%% Run
accuracies = cell(length(classifiers), 1);
classifierNames = cell(length(classifiers), 1);
for i = 1:length(classifiers)
    runner = curry(@runAndGetAccuracy, classifiers{i});
    accuracies{i} = crossval(runner, images', labels);
    classifierNames{i} = classifiers{i}.getName();
end

% display
barwitherr(std(accuracies{:}), mean(accuracies{:}));
set(gca, 'XTick', 1:length(classifierNames), 'XTickLabel', classifierNames);
end
