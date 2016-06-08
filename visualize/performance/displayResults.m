function displayResults(results)

if ~iscell(results)
    results = {results};
end

%% Prepare
percentsBlack = [65:5:95, 99];
percentsVisible = 100 - percentsBlack;
kfolds = length(results);
classifierNames = unique(results{1}.name);
chanceLevel = 100 / length(unique(results{1}.truth));
accuracies = zeros(length(percentsVisible), length(classifierNames), ...
    kfolds);
for iBlack = 1:length(percentsBlack)
    percentBlackMax = Inf;
    if iBlack < length(percentsBlack)
        percentBlackMax = percentsBlack(iBlack + 1);
    end
    accuracies(iBlack, :, :) = collectAccuracies(results, ...
        percentsBlack(iBlack), percentBlackMax, classifierNames);
end
dimKfolds = 3;
meanValues = mean(accuracies, dimKfolds, 'omitnan');
standardErrorOfTheMean = std(accuracies, 0, dimKfolds, 'omitnan') / ...
    sqrt(kfolds);

%% Graph
% rotate to properly display on pdf
orient portrait;
set(gcf, 'papersize', [11 8.5]);
set(gcf, 'paperposition', [.25 .25 10.5 8]);
% plots
hold on;
xlim([min(percentsVisible)-3, max(percentsVisible)+8]);
errorbar(permute(repmat(percentsVisible, length(classifierNames), 1), [2 1]), ...
    meanValues, standardErrorOfTheMean, 'o-');
plot(get(gca,'xlim'), [chanceLevel chanceLevel], '--k');
xlabel('Percent Visible');
ylabel('Performance');
% text labels
for i = 1:size(classifierNames)
    text(percentsVisible(1) + 1, meanValues(1, i), ...
        strrep(classifierNames{i}, '_', '\_'));
end
% human
if chanceLevel == 20
    ylim([0 100]);
    plotHumanPerformance(percentsBlack);
end
hold off;
