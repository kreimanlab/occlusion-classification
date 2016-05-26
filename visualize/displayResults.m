function displayResults(results)
if ~exist('chanceLevel', 'var')
end

%% Prepare
percentsBlack = [65:5:95, 99];
percentsVisible = 100 - percentsBlack;
classifierNames = unique(results{1}.name);
chanceLevel = 100 / length(unique(results{1}.truth));
accuracies = zeros(length(percentsVisible), length(classifierNames), ...
    length(results));
for iPb = 1:length(percentsBlack)
    for iCls = 1:length(classifierNames)
        for ik = 1:length(results)
            currentData = results{ik};
            currentData = currentData(...
                currentData.pres <= 300 & ...
                currentData.black >= percentsBlack(iPb) & ...
                strcmp(currentData.name, classifierNames{iCls}), :);
            if iPb < length(percentsBlack)
                currentData = currentData(...
                    currentData.black < percentsBlack(iPb + 1), :);
            end
            accuracies(iPb, iCls, ik) = 100 * mean(currentData.correct);
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
plotHumanPerformance(percentsBlack);
hold off;
