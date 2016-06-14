function results = plotRnnTrain1CatResults(file)
if ~exist('file', 'var')
    file = 'data/results/classification/data_occlusion_klab325v2_with_models.mat';
end
results = load(file);
results = results.data;
results.name = repmat({'RNN_train1cat'}, [size(results, 1) 1]);
displayResults(results, @collectAccuracies);
end

function accuracies = collectAccuracies(results, ...
    percentBlackMin, percentBlackMax, classifierNames)
assert(length(results) == 1);
assert(length(classifierNames) == 1);
currentData = results{1};
currentData = currentData(...
    currentData.pres <= 300 & ...
    currentData.black >= percentBlackMin & ...
    currentData.black < percentBlackMax & ...
    strcmp(currentData.name, classifierNames{1}), :);
accuracies = 100 * mean(currentData.correct);
end
