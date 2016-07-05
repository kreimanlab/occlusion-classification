function plotExemplarCorrelationsOverTime(corrData)
%PLOTEXEMPLARCORRELATIONSOVERTIME plots exemplar correlations 
%("point-cloud") of model compared to human over time

subplotRows = size(corrData.modelTimestepNames, 1);
subplotCols = size(corrData.modelTimestepNames, 2);
[labelNames, colors] = getCategoryLabels();
for modelType = 1:size(corrData.modelTimestepNames, 1)
    for timestep = 1:size(corrData.modelTimestepNames, 2)
        subplot(subplotRows, subplotCols, ...
            (modelType - 1) * subplotCols + timestep);
        hold on;
        plot(100 * corrData.humanCorrect, ...
            100 * corrData.modelCorrect(:, modelType, timestep),...
            '.', 'Color', [.7 .7 .7], 'MarkerSize', 10);
        h = lsline; set(h, 'Color', 'k');
        for pres = corrData.presIds
            category = corrData.humanResults.truth(...
                find(corrData.humanResults.pres == pres, 1));
            plot(100 * corrData.humanCorrect(pres), ...
                100 * corrData.modelCorrect(pres, modelType, timestep),...
                '.', 'Color', colors{category}, 'MarkerSize', 10);
        end
        correlation = corr(corrData.modelCorrect(:, modelType, timestep), ...
            corrData.humanCorrect(:, 1));
        title(sprintf('t = %d, r = %.2f', ...
            corrData.timesteps(modelType,timestep), correlation));
        xlabel('Performance (human)'); axis square;
        if(timestep == 1)
            ylabel(['Performance (' corrData.modelNames{modelType} ')']);
        end
        if modelType == 1 && timestep == size(corrData.modelTimestepNames, 2)
            labelDummies = zeros(size(colors));
            for c = 1:length(colors)
                labelDummies(c) = plot(NaN, NaN, colors{c});
            end
            leg = legend(labelDummies, labelNames, ...
                'Orientation', 'horizontal');
            set(leg, 'Position', [0.37 0.8 0.3 0.05], ...
                'Units', 'normalized');
        end
        hold off;
    end
end
