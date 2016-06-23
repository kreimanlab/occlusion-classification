function plotWholeVsOccludedTsne(featureExtractors)

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
    featureExtractors = {...
        featureProviderFactory.get(AlexnetFc7Features()), ...
%         featureProviderFactory.get(HopFeatures(15, BipolarFeatures(0, AlexnetFc7Features()))), ...
%         featureProviderFactory.get(HopFeatures(100, BipolarFeatures(0, AlexnetFc7Features()))); ...
%         featureProviderFactory.get(AlexnetFc7Features()), ...
%         RnnFeatureProvider(dataset, RnnFeatures(2, [])), ...
%         RnnFeatureProvider(dataset, RnnFeatures(4, []))...
        };
end

[labelNames, colors] = getCategoryLabels();
[numRows, numCols] = size(featureExtractors);
for featIter = 1:numRows
    % show over time
    for timeIter = 1:numCols
        extractorName = featureExtractors{featIter, timeIter}.getName();
        fprintf('%s (%d.%d/%d.%d)\n', extractorName, ...
            featIter, timeIter, numRows, numCols);
        extractor = featureExtractors{featIter, timeIter};
        wholeFeatures = extractor.extractFeatures(rows, RunType.Train);
        occludedFeatures = extractor.extractFeatures(rows, RunType.Test);
        labels = dataset.truth(rows);
        mappedX = tsne([wholeFeatures', occludedFeatures']', [], 2);
        mappedXWhole = mappedX(1:size(wholeFeatures, 1), :);
        mappedXOccluded = mappedX(size(wholeFeatures, 1) + 1:end, :);
        % plot x, y
        ax = subplot(numRows, numCols, (featIter - 1) * numCols + timeIter);
        set(gca, 'XTickLabel', ''); set(gca, 'YTickLabel', '');
        hold(ax, 'on');
        categoryLabels = getCategoryLabels(labels);
        gscatter(mappedXWhole(:, 1), mappedXWhole(:, 2), ...
            categoryLabels, cell2mat(colors), 'o', [], false);
        gscatter(mappedXOccluded(:, 1), mappedXOccluded(:, 2), ...
            categoryLabels, cell2mat(colors), '.', [], false);
        if (timeIter == 1)
            makeLegend(labelNames, colors);
        end
        hold off;
        title(strrep(extractor.getName(), '_', '\_'));
        set(gca, 'box', 'off');
        axis off;
    end
    set(gcf, 'Color', 'w');
end
end

function makeLegend(labels, colors)
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
h(2) = plot(NaN, NaN, '.k', 'MarkerSize', 20);
legend(h, 'Whole', 'Partial');
legend boxoff;
end
