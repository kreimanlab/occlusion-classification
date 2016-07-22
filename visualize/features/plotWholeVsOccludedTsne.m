function figures = plotWholeVsOccludedTsne(featureExtractors, figurePrefix)

% data
dataset = load('data/data_occlusion_klab325v2.mat');
dataset = dataset.data;
dataSelection = 1:13000;
% selection
[~, rows] = unique(dataset.pres(:)); % pick one version of each object
rows = rows';
% feature extractors
if ~exist('featureExtractors', 'var')
    featureProviderFactory = FeatureProviderFactory(dataset, dataSelection);
    featureExtractors = {featureProviderFactory.get(AlexnetFc7Features())};
end
if ~iscell(featureExtractors)
    featureExtractors = {featureExtractors};
end

[labelNames, colors] = getCategoryLabels();
[numRows, numCols] = size(featureExtractors);
figures = NaN(numRows * numCols, 1);
for featIter = 1:numRows
    % show over time
    for timeIter = 1:numCols
        rng(0, 'twister');
        extractor = featureExtractors{featIter, timeIter};
        fprintf('%s (%d.%d/%d.%d)\n', extractor.getName(), ...
            featIter, timeIter, numRows, numCols);
        figures((featIter - 1) * numCols + timeIter) = ...
            figure('Name', [figurePrefix, '-', extractor.getName()]);
        plotTsne(extractor, rows, dataset, colors);
        if (timeIter == 1)
            makeLegend(labelNames, colors);
        end
    end
    set(gcf, 'Color', 'w');
end
end

function plotTsne(extractor, rows, dataset, colors)
rng(0, 'twister');
wholeFeatures = extractor.extractFeatures(rows, RunType.Train);
occludedFeatures = extractor.extractFeatures(rows, RunType.Test);
labels = dataset.truth(rows);
mappedX = tsne([wholeFeatures', occludedFeatures']', [], 2);
mappedXWhole = mappedX(1:size(wholeFeatures, 1), :);
mappedXOccluded = mappedX(size(wholeFeatures, 1) + 1:end, :);
% plot x, y
set(gca, 'XTickLabel', ''); set(gca, 'YTickLabel', '');
hold on;
categoryLabels = getCategoryLabels(labels);
gscatter(mappedXOccluded(:, 1), mappedXOccluded(:, 2), ...
    categoryLabels, cell2mat(colors), '.', 10, false);
gscatter(mappedXWhole(:, 1), mappedXWhole(:, 2), ...
    categoryLabels, cell2mat(colors), 'o', 5, false);
title(strrep(extractor.getName(), '_', '\_'));
set(gca, 'box', 'off');
axis off;
hold off;
end

function makeLegend(labels, colors)
hold on;
% labels
distance = 7;
xl = xlim();
yl = ylim();
x = repmat(xl(1), size(labels));
y = yl(2):-distance:yl(2) - distance * numel(labels);
for i = 1:numel(labels)
    text(x(i), y(i), labels{i}, 'Color', colors{i});
end
% whole/partial
h = NaN(2, 1);
h(1) = plot(NaN, NaN, 'ok', 'MarkerSize', 5);
h(2) = plot(NaN, NaN, '.k', 'MarkerSize', 10);
legend(h, 'Whole', 'Partial');
legend boxoff;
hold off;
end
