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

function plotOverallHumanPerformance()
humanResults = load('data/data_occlusion_klab325v2.mat');
humanResults = filterHumanData(humanResults.data);
performance = mean(humanResults.correct) * 100;
xlim = get(gca,'xlim');
line(xlim, [performance performance], 'Color', 'black');
text(xlim(1) + (xlim(2) - xlim(1)) / 10, performance + 5, 'human');
end
