function plotCategoryCorrelationOverTime(corrData)
%PLOTCATEGORYPERFORMANCEOVERTIM plot the correlation of every single
%category over time

% [categories, colors] = getCategoryLabels();
[categories, colors] = getCategoryLabels(5);
[~, lineStyles, markers] = getModelLabels();
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
        squeeze(humanCorrectHalfs(category, :, 1)), ...
        squeeze(humanCorrectHalfs(category, :, 2)));
end

% models
numTimes = size(corrData.timesteps, 2);
modelCorrect = NaN(numel(categories), numel(corrData.modelNames), ...
    numTimes, presPerCategory); % c x m x t x p
modelHumanCorr = NaN(numel(categories), numel(corrData.modelNames), ...
    numTimes);
for category = 1:numel(categories)
    categoryXLeft = (category - 1) * numTimes + 1;
    categoryXRight = categoryXLeft + numTimes - 1;
    for model = 1:numel(corrData.modelNames)
        for timeIter = 1:numTimes
            modelCorrect(category, model, timeIter, :) = corrData.modelCorrect(...
                categoriesPres(category, :), model, timeIter);
            modelHumanCorr(category, model, timeIter) = corr(...
                squeeze(modelCorrect(category, model, timeIter, :)), ...
                squeeze(humanCorrect(category, :)));
            fprintf('category = %s, model = %s, t = %d => val = %.2f\n', ...
                categories{category}, corrData.modelNames{model}, ...
                corrData.timesteps(model, timeIter), modelHumanCorr(category, model, timeIter));
        end
        plot(categoryXLeft:categoryXRight, ...
            squeeze(modelHumanCorr(category, model, :)), ...
            [colors{category}, lineStyles{model}, markers{model}]);
        hold on;
    end
    plot([categoryXLeft, categoryXRight], ...
        [humanHumanCorrs(category), humanHumanCorrs(category)], ...
        colors{category});
end
plot(get(gca, 'xlim'), ...
    [corrData.humanHumanCorrelation corrData.humanHumanCorrelation], '-k');
categoriesModelsLegend();
end
