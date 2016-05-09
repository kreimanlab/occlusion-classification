function compareClassifiers()
addpath('./data');
addpath('./pixel');
addpath('./hmax');
addpath('./alexnet');
addpath(genpath('./helper'));

%% Setup
% data
[images, labels] = getExperimentalData([1:10, 66:75]);
% classifiers
classifiers = {SvmClassifier(), ...
    HmaxClassifier(), ...
    AlexnetFc7Classifier(), AlexnetPool5Classifier()};
cachingClassifierConstructor = curry(@CachingClassifier, images);
classifiers = cellfun(@(c) {cachingClassifierConstructor(c)}, classifiers);
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
barwitherr(std(cell2mat(accuracies')), mean(cell2mat(accuracies')));
set(gca, 'XTick', 1:length(classifierNames), 'XTickLabel', classifierNames);
end
