function plotConfusionMatrix(targets, outputs, xlabelText, ylabelText)
if ~exist('xlabelText', 'var')
    xlabelText = 'Targets';
end
if ~exist('ylabelText', 'var')
    ylabelText = 'Outputs';
end
%% compute
C = confusionmat(targets, outputs);
valuesSum = sum(C(:));
accuracy = sum(diag(C)) / valuesSum;
C = C' / valuesSum;
% summed up sides
CSums = NaN(size(C, 1), 2);
CSums(:, 1) = sum(C, 1);
CSums(:, 2) = sum(C, 2);
C(end+1, :) = CSums(:, 1);
C(1:end-1, end+1) = CSums(:, 2);
C(end, end) = accuracy;

%% plot
imagesc(100 * C);
colormap(flipud(gray));
% separate summaries
line(repmat(size(C, 2) - 0.5, [1, 2]), [0.5, size(C, 1) + 0.5], ...
    'LineWidth', 2, 'Color', 'black');
line([0.5, size(C, 2) + 0.5], repmat(size(C, 1) - 0.5, [1, 2]), ...
    'LineWidth', 2, 'Color', 'black');
% labels
xlabel(xlabelText);
ylabel(ylabelText);
categories = getCategoryLabels();
set(gca, 'xaxisLocation', 'top');
set(gca, 'XTick', 1:numel(categories));
set(gca, 'YTick', 1:numel(categories));
set(gca, 'XTickLabel', categories);
set(gca, 'YTickLabel', categories);
% text
[xs, ys] = meshgrid(1:size(C, 1), 1:size(C, 2));
textString = arrayfun(@(i) sprintf('%.2f%%', i), 100 * C, ...
    'UniformOutput', false);
for i = 1:numel(xs)
text(xs(i) - 0.25, ys(i), textString(i), ...
    'Color', repmat(C(i) / max(C(:)), [1, 3]));
end
end
