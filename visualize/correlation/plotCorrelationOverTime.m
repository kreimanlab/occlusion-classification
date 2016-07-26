function plotCorrelationOverTime(corrData)
%PLOTCORRELATIONOVERTIME plots the overall correlations of model
%compared to human

barwitherr(squeeze(stderrmean(corrData.modelHumanCorrelations, 1))', ...
    squeeze(mean(corrData.modelHumanCorrelations, 1))', ...
    'EdgeColor', 'none');
box off;
hold on;
shadedErrorBar(xlim(), ...
    repmat(mean(corrData.humanHumanCorrelations), [1, 2]), ...
    repmat(stderrmean(corrData.humanHumanCorrelations), [1, 2]), ...
    {'Color', 'k'}, true);
ylim([-0.65 1]);
% labels
xlabels = makeXLabels(corrData.timesteps);
my_xticklabels(1:length(xlabels), xlabels);
legend(corrData.modelNames);
set(gca,'TickDir', 'in');
set(gca,'TickLength', [0.02 0.02]);
set(gca,'XTick', 1:length(corrData.modelTimestepNames));
xlabel('Time step');
ylabel('Corr. with Human');
set(gcf, 'Color', 'w');
box off;
hold off;
end
