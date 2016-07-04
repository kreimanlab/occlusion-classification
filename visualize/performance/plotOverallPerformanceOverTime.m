function plotOverallPerformanceOverTime(results)
if iscell(results)
    results = vertcat(results{:});
end

[modelNames, modelTimestepNames, timesteps] = ...
    collectModelProperties(results);
performances = NaN(size(timesteps));
for i = 1:numel(timesteps)
    currentResults = results(strcmp(results.name, modelTimestepNames{i}), :);
    performances(i) = mean(currentResults.correct);
end
performances = performances * 100;
plots = plotWithScaledX(timesteps, performances);
hold on;
for modelType = 1:numel(modelNames)
    text(length(timesteps(modelType, :)) - 1, ...
        mean(performances(modelType, :), 'omitnan'), ...
        modelNames{modelType}, 'Color', get(plots{modelType}, 'Color'));
end
xlabel('Time step');
ylabel('Performance');
ylim([0 100]);
plotOverallHumanPerformance();
set(gcf, 'Color', 'w');
box off;
hold off;
end
