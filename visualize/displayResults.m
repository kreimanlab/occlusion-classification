function displayResults(results, chanceLevel)
if ~exist('chanceLevel', 'var')
    chanceLevel = 20;
end

%% Prepare
percentsVisible = 0:5:35;
visibilityMargin = (percentsVisible(2) - percentsVisible(1)) / 2;
classifierNames = unique(results{1}.name);
accuracies = zeros(length(percentsVisible), length(classifierNames), ...
    length(results));
for iPv = 1:length(percentsVisible)
    percentBlack = 100 - percentsVisible(iPv);
    for iCls = 1:length(classifierNames)
        for ik = 1:length(results)
            currentData = results{ik};
            currentData = currentData(...
                currentData.pres <= 300 & ...
                currentData.black >  percentBlack - visibilityMargin & ...
                currentData.black <= percentBlack + visibilityMargin & ...
                strcmp(currentData.name, classifierNames{iCls}), :);
            accuracies(iPv, iCls, ik) = 100 * ...
                sum(currentData.correct) / length(currentData);
        end
    end
end
meanValues = mean(accuracies, 3, 'omitnan');
standardErrorOfTheMean = std(accuracies, 0, 3, 'omitnan') / ...
    sqrt(size(accuracies, 3));

%% Graph
figure();
% rotate to properly display on pdf
orient portrait;
set(gcf, 'papersize', [11 8.5]);
set(gcf, 'paperposition', [.25 .25 10.5 8]);
% plots
hold on;
xlim([min(percentsVisible)-3, max(percentsVisible)+8]);
ylim([0 100]);
errorbar(permute(repmat(percentsVisible, size(results, 2), 1), [2 1]), ...
    meanValues, standardErrorOfTheMean, 'o-');
plot(get(gca,'xlim'), [chanceLevel chanceLevel], '--k');
xlabel('Percent Visible');
ylabel('Performance');
% text labels
for i = 1:size(classifierNames)
    text(percentsVisible(end) + 1, meanValues(end, i), ...
        strrep(classifierNames{i}, '_', '\_'));
end
% human
plotHumanPerformance(percentsVisible);
hold off;
