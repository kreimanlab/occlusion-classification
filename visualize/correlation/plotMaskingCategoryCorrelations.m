function plotMaskingCategoryCorrelations(modelHumanCorrelationsPerCategory, humanTimesteps, modelTimesteps)
% accumulate
modelHumanMean = squeeze(mean(modelHumanCorrelationsPerCategory, 3));
% plot
xvalues = humanTimesteps;
yvalues = modelTimesteps;
h = heatmap(xvalues, yvalues, modelHumanMean');

h.XLabel = 'human SOA';
h.YLabel = 'model SOA';
% 
% set(gca,'TickDir', 'in');
% set(gca,'TickLength', [0.02 0.02]);
% set(gca,'XTick', 1:length(corrData.modelTimestepNames));
% set(gcf, 'Color', 'w');
% box off;
% hold off;
end
