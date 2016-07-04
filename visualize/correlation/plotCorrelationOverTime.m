function plotCorrelationOverTime(corrData)
%PLOTCORRELATIONOVERTIME plots the overall correlations of model
%compared to human

bar(corrData.modelHumanCorrelations', 'EdgeColor', 'none');
box off;
hold on;
plot(get(gca, 'xlim'), [corrData.humanHumanCorrelation corrData.humanHumanCorrelation], ...
    '-', 'Color', [1 0 0]);
ylim([-0.65 1]);
% labels
xlabels = makeXLabels(corrData.timesteps);
my_xticklabels(1:length(xlabels), xlabels);
set(gca,'TickDir', 'in');
set(gca,'TickLength', [0.02 0.02]);
set(gca,'XTick', 1:length(corrData.modelTimestepNames));
for i = 1:size(corrData.modelNames, 1)
    text(mean(get(gca, 'xlim')), mean(corrData.modelHumanCorrelations(i, :)), ...
        corrData.modelNames{i});
end
xlabel('Time step');
ylabel('Corr. with Human');
set(gcf, 'Color', 'w');
box off;
hold off;
end
