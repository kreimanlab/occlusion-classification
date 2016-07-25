function figures = plotWholeVsOccludedTsne(...
    featureExtractors, figurePrefix)

% data
dataset = load('data/data_occlusion_klab325v2.mat');
dataset = dataset.data;
dataSelection = 1:size(dataset, 1);
featureProviderFactory = FeatureProviderFactory(dataset, dataSelection);
% selection
[~, rows] = unique(dataset.pres(:)); % pick one version of each object
rows = rows';
% labels(whole) == labels(occluded) since they belong to the same category
labels = dataset.truth(rows);
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
    wholeFeatures = NaN(325, 4096);
    occludedFeatures = NaN(numel(rows) * numCols, 4096);
    % show over time
    for timeIter = 1:numCols
        extractor = featureExtractors{featIter, timeIter};
        providedExtractor = featureProviderFactory.get(extractor);
        fprintf('%s (%d.%d/%d.%d)\n', providedExtractor.getName(), ...
            featIter, timeIter, numRows, numCols);
        if timeIter == 1
            wholeFeatures(:) = ...
                providedExtractor.extractFeatures(rows, RunType.Train);
        end
        occludedFeatures((timeIter - 1) * numel(rows) + 1:...
            timeIter * numel(rows), :) = ...
            providedExtractor.extractFeatures(rows, RunType.Test);
        % we usually don't need the extractor again, free up memory space
        featureProviderFactory.remove(extractor);
    end
    assert(~any(isnan(occludedFeatures(:))));
    % do tsne
    rng(0, 'twister');
    mappedX = tsne([wholeFeatures; occludedFeatures], [], 2);
    mappedXWhole = mappedX(1:size(wholeFeatures, 1), :);
    % plot
    for timeIter = 1:numCols
        extractor = featureExtractors{featIter, timeIter};
        mappedXOccluded = mappedX(...
            size(wholeFeatures, 1) + (timeIter - 1) * numel(rows) + 1:...
            size(wholeFeatures, 1) + timeIter * numel(rows), :);
        figures((featIter - 1) * numCols + timeIter) = figure('Name', ...
            sprintf('%s%d-%s', figurePrefix, timeIter, extractor.getName()));
        plotTsne(mappedXWhole, mappedXOccluded, labels, colors, extractor);
        if timeIter == 1
            makeLegend(labelNames, colors);
        end
    end
    set(gcf, 'Color', 'w');
end
end

function plotTsne(mappedXWhole, mappedXOccluded, labels, colors, extractor)
    categoryLabels = getCategoryLabels(labels);
    gscatter(mappedXOccluded(:, 1), mappedXOccluded(:, 2), ...
        categoryLabels, cell2mat(colors), '.', 10, false);
    hold on;
    gscatter(mappedXWhole(:, 1), mappedXWhole(:, 2), ...
        categoryLabels, cell2mat(colors), 'o', 5, false);
    title(strrep(extractor.getName(), '_', '\_'));
    set(gca, 'XTickLabel', ''); set(gca, 'YTickLabel', '');
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
