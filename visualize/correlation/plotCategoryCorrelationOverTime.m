function plotCategoryCorrelationOverTime(corrData)
%PLOTCATEGORYPERFORMANCEOVERTIM plot the correlation of every single
%category over time

categories = getCategoryLabels();
data = load('data/data_occlusion_klab325v2.mat');
data = data.data;
data = data(data.pres <= 300, :);
presPerCategory = 60;
categoriesPres = NaN(numel(categories), presPerCategory);
for category = 1:numel(categories)
    pres = unique(data.pres(data.truth == category));
    categoriesPres(category, :) = pres;
end

% human
humanCorrect = NaN(numel(categories), presPerCategory);
humanCorrectHalfs = NaN([numel(categories), presPerCategory, 2]);
humanHumanCorrs = NaN(numel(categories), 1);
for category = 1:numel(categories)
    humanCorrect(category, :) = ...
        corrData.humanCorrect(categoriesPres(category, :));
    for half = 1:2
        humanCorrectHalfs(category, :, half) = ...
            corrData.humanCorrectHalfs(categoriesPres(category, :), half);
    end
    humanHumanCorrs(category) = corr(...
        squeeze(humanCorrectHalfs(category, :, 1))', ...
        squeeze(humanCorrectHalfs(category, :, 2))');
end

% models
numTimes = size(corrData.timesteps, 2);
modelCorrect = NaN(numel(categories), numel(corrData.modelNames), ...
    numTimes, presPerCategory); % c x m x t x p
modelHumanCorr = NaN(numel(categories), numel(corrData.modelNames), ...
    numTimes);
for category = 1:numel(categories)
    for model = 1:numel(corrData.modelNames)
        for timeIter = 1:numTimes
            modelCorrect(category, model, timeIter, :) = corrData.modelCorrect(...
                categoriesPres(category, :), model, timeIter);
            modelHumanCorr(category, model, timeIter) = corr(...
                squeeze(modelCorrect(category, model, timeIter, :)), ...
                squeeze(humanCorrect(category, :))');
        end
    end
end
% accumulate
meanModelHumanCorrelation = squeeze(mean(modelHumanCorr, 1))';
meanHumanHumanCorrelation = mean(humanHumanCorrs);
% plot
bar(meanModelHumanCorrelation, 'EdgeColor', 'none');
hold on;
line(get(gca, 'xlim'), [meanHumanHumanCorrelation, meanHumanHumanCorrelation], ...
    'Color', 'k', 'LineStyle', '--');
legend(corrData.modelNames);
xlabels = makeXLabels(corrData.timesteps);
my_xticklabels(1:length(xlabels), xlabels);
xlabel('Time step');
ylabel('Mean per-Category Corr. with Human');
ylim([0 0.5]);
set(gca,'TickDir', 'in');
set(gca,'TickLength', [0.02 0.02]);
set(gca,'XTick', 1:length(corrData.modelTimestepNames));
set(gcf, 'Color', 'w');
box off;
hold off;
end
