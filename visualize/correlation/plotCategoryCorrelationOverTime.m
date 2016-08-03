function plotCategoryCorrelationOverTime(corrData)
%PLOTCATEGORYPERFORMANCEOVERTIM plot the correlation of every single
%category over time

% accumulate
humanHumanMean = squeeze(mean(mean(...
    corrData.humanHumanCorrelationsPerCategory, 1), 2))';
humanHumanErr = squeeze(stderrmean(stderrmean(...
    corrData.humanHumanCorrelationsPerCategory, 1), 2))';
modelHumanMean = squeeze(mean(...
    corrData.modelHumanCorrelationsPerCategory, 1))';
modelHumanErr = squeeze(stderrmean(...
    corrData.modelHumanCorrelationsPerCategory, 1))';
% plot
plots = barwitherr(modelHumanErr, modelHumanMean, ...
    'EdgeColor', 'none');
adjustModelColors(plots, corrData.modelNames, 'FaceColor');
hold on;
shadedErrorBar(xlim(), ...
    [humanHumanMean, humanHumanMean], ...
    [humanHumanErr, humanHumanErr], ...
    {'Color', 'k'}, true);
legend(corrData.modelNames);
xlabels = makeXLabels(corrData.timesteps);
my_xticklabels(1:length(xlabels), xlabels);
xlabel('Time step');
ylabel('Mean per-Category Correlation with Human');
ylim([0 0.5]);
set(gca,'TickDir', 'in');
set(gca,'TickLength', [0.02 0.02]);
set(gca,'XTick', 1:length(corrData.modelTimestepNames));
set(gcf, 'Color', 'w');
box off;
hold off;
end
