function plotConfusionMatricesOverTime(modelResults, ...
    modelField, humanField, classes)
if ~exist('modelField', 'var')
    modelField = 'correct';
end
if ~exist('humanField', 'var')
    humanField = modelField;
end
if ~exist('classes', 'var')
    classes = getCategoryLabels();
end
% human
humanResults = load('data/data_occlusion_klab325v2.mat');
[humanResults, relevantRows] = filterHumanData(humanResults.data);
% model
modelResults = collapseResults(modelResults);
[modelNames, modelTimestepNames, timesteps] = ...
    collectModelProperties(modelResults);
numModelNames = size(modelNames, 1);
numTimesteps = size(timesteps, 2);
for modelType = 1:numModelNames
    for timestep = 1:numTimesteps
        if isempty(modelTimestepNames{modelType, timestep})
            continue;
        end
        subplot(numModelNames, numTimesteps, ...
            (modelType - 1) * numTimesteps + timestep);
        currentResults = modelResults(strcmp(modelResults.name, ...
            modelTimestepNames{modelType, timestep}), :);
        currentResults = arrayfun(@(row) currentResults(...
            currentResults.testrows == row, :), find(relevantRows), ...
            'UniformOutput', false);
        currentResults = collapseResults(currentResults);
        plotConfusionMatrix(...
            humanResults.(humanField), currentResults.(modelField), ...
            'Human', modelNames{modelType}, classes);
        title(sprintf('%s, t=%d', ...
            modelNames{modelType}, timesteps(modelType, timestep)));
    end
end
end
