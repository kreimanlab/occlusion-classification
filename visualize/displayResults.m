function displayResults(percentsVisible, results)

accuracies = 100 * reshape([results.accuracy], size(results));
meanValues = mean(accuracies, 3);
figure();
% rotate to properly display on pdf
orient portrait;
set(gcf, 'papersize', [11 8.5]);
set(gcf, 'paperposition', [.25 .25 10.5 8]);
% plot
hold on;
xlim([min(percentsVisible)-3, max(percentsVisible)+8]);
ylim([0 100]);
errorbar(permute(repmat(percentsVisible, size(results, 2), 1), [2 1]), ...
    meanValues, std(accuracies, 0, 3), 'o-');
plot(get(gca,'xlim'), [20 20], '--k');
xlabel('Percent Visible');
ylabel('Performance');
% text labels
for i = 1:size(results, 2)
    text(percentsVisible(end) + 1, meanValues(end, i), ...
        results(1, i, 1).name);
end
hold off;