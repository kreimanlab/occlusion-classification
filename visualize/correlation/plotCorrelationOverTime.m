function plotCorrelationOverTime(corrData)
%PLOTCORRELATIONOVERTIME plots the overall correlations of model
%compared to human

bar(corrData.modelHumanCorrelations', 'EdgeColor', 'none');
box off;
hold on;
line(get(gca, 'xlim'), ...
    [corrData.humanHumanCorrelation corrData.humanHumanCorrelation], ...
    'Color', 'k', 'LineStyle', '--');
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
