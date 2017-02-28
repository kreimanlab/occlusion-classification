function accuracies = collectAccuracies(results, ...
    percentBlackMin, percentBlackMax, classifierNames)
if ~exist('percentBlackMin', 'var')
    percentBlackMin = intmin;
end
if ~exist('percentBlackMax', 'var')
    percentBlackMax = intmax;
end
if ~exist('classifierNames', 'var')
    classifierNames = unique(results{1}.name);
end

accuracies = NaN(length(classifierNames), length(results));
for iCls = 1:length(classifierNames)
    for ikfold = 1:length(results)
        currentData = results{ikfold};
        currentData = currentData(...
            currentData.pres <= 300 & ...
            currentData.black >= percentBlackMin & ...
            currentData.black < percentBlackMax & ...
            strcmp(currentData.name, classifierNames{iCls}), :);
        accuracies(iCls, ikfold) = 100 * mean(currentData.correct);
    end
end
end
