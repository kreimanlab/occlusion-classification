function displayResults(percentsVisible, results)

accuracies = 100 * reshape([results.accuracy], size(results));
classifierNames = {results(1, :, 1).name};
figure();
% rotate to properly display on pdf
orient portrait;
set(gcf, 'papersize', [11 8.5]);
set(gcf, 'paperposition', [.25 .25 10.5 8]);
% plot
hold on;
xlim([min(percentsVisible)-3, max(percentsVisible)+3]);
ylim([0 100]);

errorbar(permute(repmat(percentsVisible, size(results, 2), 1), [2 1]), ...
    mean(accuracies, 3), std(accuracies, 0, 3), 'o-');
plot(get(gca,'xlim'), [20 20], '--k');
xlabel('Percent Visible');
ylabel('Performance');
legend(classifierNames);
hold off;