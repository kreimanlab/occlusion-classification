function corrData = plotCategoryCorrelationExemplarsOverTime(corrData)

%% data
if ~exist('corrData', 'var')
    corrTimestepsRnn = [0, 2, 4];
    corrTimestepsHop = [1, 20, 100];
    results = load('data/results/classification/all-libsvmccv.mat');
    results = results.results;
    rnnResults = convertRnnResults();
    timeResultsHop = load('data/results/classification/hoptimes-trainAll.mat');
    timeResultsHop = timeResultsHop.results;
    timeResultsHop = mergeResults(...
        filterResults(results, @(r) ismember(r.name, ...
        {'caffenet_fc7', 'caffenet_fc7-bipolar0'})), ...
        filterResults(timeResultsHop, @(r) cellfun(@(m) ~isempty(m), ...
        regexp(r.name, ['caffenet_fc7-bipolar0-hop_t(' ...
        [sprintf('%d|', corrTimestepsHop(1:end-1)), num2str(corrTimestepsHop(end))] ')-libsvmccv']))));
    corrResults = mergeRnnResults(...
        filterResults(timeResultsHop, @(r) cellfun(@(m) ~isempty(m), ...
        regexp(r.name, ['^caffenet_fc7-bipolar0-hop_t(' ...
        timesteps2regexp(corrTimestepsHop) ')-']))), ...
        filterResults(rnnResults, @(r) cellfun(@(m) ~isempty(m), ...
        regexp(r.name, ['RNN_t(' timesteps2regexp(corrTimestepsRnn) ')']))));
    corrData = collectModelHumanCorrelationData(corrResults);
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
figure('Name', 'human-human');
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
    humanHumanCorrs(categoryIter) = corr(half1, half2);
    
    subplot(1, numel(categories) + 1, categoryIter);
    plot(100 * half1, 100 * half2, ...
        '.', 'Color', colors{categoryIter}, 'MarkerSize', 10);
    hold on; lsline; hold off;
    title(sprintf('corr = %.2f', humanHumanCorrs(categoryIter)));
end
subplot(1, numel(categories) + 1, numel(categories) + 1);
plot(100 * squeeze(humanCorrectHalfs(:, :, 1)), ...
    100 * squeeze(humanCorrectHalfs(:, :, 2)), ...
    '.', 'Color', [0.7 0.7 0.7], 'MarkerSize', 10);
hold on; lsline; hold off;
title(sprintf('mean corr = %.2f', mean(humanHumanCorrs(:))));

% models
numCategories = numel(categoryLabels);
numTimes = size(corrData.timesteps, 2);
modelCorrect = NaN(numel(categoryIter), numel(corrData.modelNames), ...
    numTimes, presPerCategory); % c x m x t x p
numRows = numTimes;
numCols = numCategories + 1;
for model = 1:numel(corrData.modelNames)
    figure('Name', sprintf('human-%s', corrData.modelNames{model}));
    for timeIter = 1:numTimes
        corrs = NaN(numCategories, 1);
        for categoryIter = 1:numel(categoryLabels)
            modelCorrect(categoryIter, model, timeIter, :) = corrData.modelCorrect(...
                categoriesPres(categoryIter, :), model, timeIter);
            modelData = squeeze(modelCorrect(categoryIter, model, timeIter, :));
            humanData = squeeze(humanCorrect(categoryIter, :));
            subplot(numRows, numCols, (timeIter - 1) * numCols + categoryIter);
            plot(100 * humanData, 100 * modelData, ...
                '.', 'Color', colors{categoryIter}, 'MarkerSize', 10);
            hold on;
            xlim([0 100]);
            ylim([0 100]);
            c = corr(humanData, modelData);
            corrs(categoryIter) = c;
            p = polyfit(humanData, modelData, 1);
            line(xlim(), p(2) + c * xlim(), 'Color', 'r');
            line(xlim(), p(2) + p(1) * xlim(), 'Color', [0.7 0.7 0.7]);
            title(sprintf('t=%d, corr=%.2f', ...
                corrData.timesteps(model, timeIter), c));
            hold off;
        end
        modelData = reshape(modelCorrect(:, model, timeIter, :), [presPerCategory * numCategories, 1]);
        humanData = reshape(humanCorrect(:, :), [presPerCategory * numCategories, 1]);
        c = mean(corrs(:));
        subplot(numRows, numCols, (timeIter - 1) * numCols + numCols);
        plot(100 * humanData, 100 * modelData, ...
            '.', 'Color', [0.7 0.7 0.7], 'MarkerSize', 10);
        hold on;
        xlim([0 100]);
        ylim([0 100]);
        line(xlim(), c * xlim(), 'Color', 'r');
        title(sprintf('t=%d, mean corr=%.2f', ...
            corrData.timesteps(model, timeIter), c));
        hold off;
    end
end
end

function str = timesteps2regexp(timesteps)
str = [sprintf('%d|', timesteps(1:end-1)), num2str(timesteps(end))];
end
