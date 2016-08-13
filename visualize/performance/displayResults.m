function displayResults(results, getAccuracies)

if ~exist('collectAccuracies', 'var')
    getAccuracies = @collectAccuracies;
end
results = joinExperimentData(results);

%% Prepare
percentsBlack = [65:5:95, 99];
if any(results{1}.black == 0)
    percentsBlack = [0, percentsBlack];
end
percentsVisible = NaN(size(percentsBlack));
kfolds = length(results);
classifierNames = unique(results{1}.name);
chanceLevel = 100 / length(unique(results{1}.truth));
accuracies = NaN(length(percentsVisible), length(classifierNames), ...
    kfolds);
for iBlack = 1:length(percentsBlack)
    [blackMin, blackMax, blackCenter] = ...
        getPercentBlackRange(percentsBlack, iBlack);
    percentsVisible(iBlack) = 100 - blackCenter;
    accuracies(iBlack, :, :) = getAccuracies(results, ...
        blackMin, blackMax, classifierNames);
end
dimKfolds = 3;
meanValues = mean(accuracies, dimKfolds, 'omitnan');
standardErrorOfTheMean = std(accuracies, 0, dimKfolds, 'omitnan') / ...
    sqrt(kfolds);

%% Graph
% plots
xlim([min(percentsVisible) - 3, max(percentsVisible) + 8]);
x = permute(repmat(percentsVisible, length(classifierNames), 1), [2 1]);
p = errorbar(x, meanValues, standardErrorOfTheMean, 'o-', 'MarkerSize', 4);
modelColors = adjustModelColors(p, classifierNames);
hold on;
% text labels
for i = 1:size(classifierNames)
    text(percentsVisible(1) + 1, meanValues(1, i), ...
        strrep(classifierNames{i}, '_', '\_'), 'Color', modelColors{i});
end
% chance
plot(get(gca,'xlim'), [chanceLevel chanceLevel], '--k');
% human
if chanceLevel == 20
    ylim([0 100]);
    plotHumanPerformance(percentsBlack);
end
xlabel('Percent Visible');
ylabel('Performance');
set(gcf, 'Color', 'w');
hold off;
