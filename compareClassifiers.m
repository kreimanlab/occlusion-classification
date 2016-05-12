function compareClassifiers()
addpath('./data');
addpath('./pixel');
addpath('./hmax');
addpath('./alexnet');
addpath(genpath('./helper'));

%% Setup
% data
dataSelection = [1:10, 66:75];
[images, labels] = getWholeImages(dataSelection);
occlusionDataProvider = OcclusionDataProvider(images, dataSelection);
% classifiers
classifiers = {PixelClassifier(), ...
    HmaxClassifier(), ...
    AlexnetFc7Classifier(), AlexnetPool5Classifier()};
classifiers = cellfun(@(c) {CachingClassifier(c)}, classifiers);
% cross validation
rng(1, 'twister'); % seed, use pseudo random generator for reproducibility

%% Run
% function to retrieve the accuracy from a run result
    function accuracy = evaluate(classifier, percentVisible, ...
            xtrain, ytrain, xtest, ytest)
        xtest = occlude(xtest, percentVisible, ...
            occlusionDataProvider.get(xtest));
        results = runClassifier(classifier, xtrain, ytrain, xtest, ytest);
        accuracy = results.accuracy;
    end
percentVisibleArray = 0:50:100;
kfold = 2;
accuracies = zeros(length(percentVisibleArray), length(classifiers), kfold);
for iPc = 1:length(percentVisibleArray)
    for iCls = 1:length(classifiers)
        runner = curry(@evaluate, ...
            classifiers{iCls}, percentVisibleArray(iPc));
        results = crossval(runner, images', labels, 'kfold', kfold);
        accuracies(iPc, iCls, :) = results(:);
    end
end

% display
accuracyPercentages = accuracies * 100;
classifierNames = cellfun(@(c) c.getName(), classifiers, ...
    'UniformOutput', false);
figure();
hold on;
xlim([min(percentVisibleArray)-3 max(percentVisibleArray)+3]);
ylim([0 100]);
errorbar(permute(repmat(percentVisibleArray, 4, 1), [2 1]), ...
    mean(accuracyPercentages, 3), std(accuracyPercentages, 0, 3), 'o-');
plot(get(gca,'xlim'), [20 20], '--k');
xlabel('Percent Visible');
ylabel('Performance');
legend(classifierNames);
hold off;
end
