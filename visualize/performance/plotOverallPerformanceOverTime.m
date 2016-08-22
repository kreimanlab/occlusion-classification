function [plots, texts] = plotOverallPerformanceOverTime(results)
%% collect
kfolds = length(results);
[modelNames, modelTimestepNames, timesteps] = ...
    collectModelProperties(results);
performances = NaN([size(timesteps), kfolds]);
for modelIter = 1:size(modelTimestepNames, 1)
    for timeIter = 1:size(modelTimestepNames, 2)
        for ikfold = 1:kfolds
            currentResults = results{ikfold};
            currentResults = currentResults(strcmp(currentResults.name, ...
                modelTimestepNames{modelIter, timeIter}), :);
            performances(modelIter, timeIter, ikfold) = ...
                100 * mean(currentResults.correct);
        end
    end
end
%% plot
meanValues = mean(performances, 3, 'omitnan');
standardErrorOfTheMean = std(performances, 0, 3, 'omitnan') / sqrt(kfolds);
plotArgs = {'o-', 'MarkerSize', 4};
plots = plotWithScaledX(timesteps, meanValues, ...
    standardErrorOfTheMean, @errorbar, plotArgs);
adjustModelColors([plots{:, 1}], modelNames);
hold on;
% text
texts = NaN(size(modelNames));
for modelIter = 1:numel(modelNames)
    texts(modelIter) = text(length(timesteps(modelIter, :)) - 1, ...
        mean(performances(modelIter, :), 'omitnan'), ...
        modelNames{modelIter}, 'Color', get(plots{modelIter}, 'Color'));
end
% labels
xlabel('Time step');
ylabel('Performance');
ylim([0 100]);
plotOverallHumanPerformance();
set(gcf, 'Color', 'w');
box off;
hold off;
end
