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
for modelType = 1:numel(modelNames)
    p = plot(performances(modelType, :), 'o-');
    hold on;
    text(length(timesteps(modelType, :))-1, ...
        mean(performances(modelType, :), 'omitnan'), ...
        modelNames{modelType}, 'Color', get(p, 'Color'));
end
xlabels = arrayfun(@(i) ...
    strjoin(cellstr(num2str(timesteps(:, i))), '\n'), ...
    1:size(timesteps, 2), ...
    'UniformOutput', false);
my_xticklabels(1:length(xlabels), xlabels);
xlabel('Time step');
ylabel('Performance');
ylim([0 100]);
plotOverallHumanPerformance();
hold off;
end
