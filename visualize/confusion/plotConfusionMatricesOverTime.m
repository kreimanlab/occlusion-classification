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
rows = numModelNames;
cols = numTimesteps + 1;
for modelType = 1:numModelNames
    % model-human
    for timestep = 1:numTimesteps
        if isempty(modelTimestepNames{modelType, timestep})
            continue;
        end
        subplot(rows, cols, ...
            (modelType - 1) * cols + timestep);
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
    % human-human
    subplot(rows, cols, (modelType - 1) * cols + numTimesteps + 1);
    [rowPartitions1, rowPartitions2] = partitionTrials(humanResults, 1);
    plotConfusionMatrix(...
        humanResults.(humanField)(rowPartitions1{1}), ...
        humanResults.(humanField)(rowPartitions2{1}), ...
        'Human', 'Human', classes);
    title('human-human');
end
end
