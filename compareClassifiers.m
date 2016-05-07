function compareClassifiers()
addpath('./data');
addpath('./pixel');
addpath('./hmax');
addpath('./alexnet');

classifiers = cell(3, 1);
classifiers{1} = SvmClassifier();
classifiers{2} = HmaxClassifier();
classifiers{3} = AlexnetClassifier();
[trainImages, trainLabels] = getExperimentalData();
testImages = trainImages;
testLabels = trainLabels;

results = cell(length(classifiers), 1);
accuracies = zeros(length(results), 1);
classifierNames = cell(length(classifiers), 1);
for i = 1:length(classifiers)
    results{i} = runClassifier(classifiers{i}, ...
        trainImages, trainLabels, testImages, testLabels);
    classifierNames{i} = results{i}.name;
    accuracies(i) = results{i}.accuracy;
end
bar(accuracies);
set(gca, 'XTick', 1:length(classifierNames), 'XTickLabel', classifierNames);
