function figures = plotCategoryCorrelationExemplarsOverTime(...
    corrData, figureNamePrefix)
figures = NaN(0);
if ~exist('figureNamePrefix', 'var')
    figureNamePrefix = '';
else
    figureNamePrefix = [figureNamePrefix, ' '];
end

categories = 1:5;
[categoryLabels, colors] = getCategoryLabels(categories);
data = load('data/data_occlusion_klab325v2.mat');
data = data.data;
data = data(data.pres <= 300, :);
presPerCategory = 60;
categoriesPres = NaN(numel(categories), presPerCategory);
for categoryIter = 1:numel(categories)
    category = categories(categoryIter);
    pres = unique(data.pres(data.truth == category));
    categoriesPres(categoryIter, :) = pres;
end

% human
humanCorrect = NaN(numel(categories), presPerCategory);
humanCorrectHalfs = NaN([numel(categories), presPerCategory, 2]);
humanHumanCorrs = NaN(numel(categories), 1);
figures(end + 1) = figure('Name', [figureNamePrefix, 'human-human']);
for categoryIter = 1:numel(categories)
    humanCorrect(categoryIter, :) = ...
        corrData.humanCorrect(categoriesPres(categoryIter, :));
    for half = 1:2
        humanCorrectHalfs(categoryIter, :, half) = ...
            corrData.humanCorrectHalfs(categoriesPres(categoryIter, :), half);
    end
    half1 = squeeze(humanCorrectHalfs(categoryIter, :, 1));
    half2 = squeeze(humanCorrectHalfs(categoryIter, :, 2));
    assert(isequal(size(half1), size(half2)));
    humanHumanCorrs(categoryIter) = corr(half1', half2');
    
    subplot(1, numel(categories), categoryIter);
    plot(100 * half1, 100 * half2, ...
        '.', 'Color', colors{categoryIter}, 'MarkerSize', 10);
    hold on; 
    h = lsline; set(h, 'Color', 'k');
    hold off;
    title(sprintf('corr = %.2f', humanHumanCorrs(categoryIter)));
end

% models
numCategories = numel(categoryLabels);
numTimes = size(corrData.timesteps, 2);
modelCorrect = NaN(numel(categoryIter), numel(corrData.modelNames), ...
    numTimes, presPerCategory); % c x m x t x p
numRows = numTimes;
numCols = numCategories;
for model = 1:numel(corrData.modelNames)
    figures(end + 1) = figure('Name', ...
        sprintf('%s%s-human', figureNamePrefix, corrData.modelNames{model}));
    for timeIter = 1:numTimes
        corrs = NaN(numCategories, 1);
        for categoryIter = 1:numel(categoryLabels)
            modelCorrect(categoryIter, model, timeIter, :) = corrData.modelCorrect(...
                categoriesPres(categoryIter, :), model, timeIter);
            modelData = squeeze(modelCorrect(categoryIter, model, timeIter, :));
            humanData = squeeze(humanCorrect(categoryIter, :))';
            subplot(numRows, numCols, (timeIter - 1) * numCols + categoryIter);
            plot(100 * humanData, 100 * modelData, ...
                '.', 'Color', colors{categoryIter}, 'MarkerSize', 10);
            hold on;
            h = lsline; set(h, 'Color', 'k');
            xlim([0 100]);
            ylim([0 100]);
            c = corr(humanData, modelData);
            corrs(categoryIter) = c;
            title(sprintf('t=%d, corr=%.2f', ...
                corrData.timesteps(model, timeIter), c));
            hold off;
        end
    end
end
end

function str = timesteps2regexp(timesteps)
str = [sprintf('%d|', timesteps(1:end-1)), num2str(timesteps(end))];
end
