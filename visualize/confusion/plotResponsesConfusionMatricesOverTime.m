function plotResponsesConfusionMatricesOverTime(results)
results = collapseResults(results);
[modelNames, modelTimestepNames, timesteps] = ...
    collectModelProperties(results);
numModelNames = size(modelNames, 1);
numTimesteps = size(timesteps, 2);
for modelType = 1:numModelNames
    for timestep = 1:numTimesteps
        if isempty(modelTimestepNames{modelType, timestep})
            continue;
        end
        subplot(numModelNames, numTimesteps, ...
            (modelType - 1) * numTimesteps + timestep);
        plotResponsesTruthConfusionMatrix(filterResults(results, ...
            @(r) strcmp(r.name, modelTimestepNames{modelType, timestep})));
        title(sprintf('%s, t=%d', ...
            modelNames{modelType}, timesteps(modelType, timestep)));
    end
end
end
