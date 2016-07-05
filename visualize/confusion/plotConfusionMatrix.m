function plotConfusionMatrix(targets, outputs, ...
    xlabelText, ylabelText, classes)
if ~exist('xlabelText', 'var')
    xlabelText = 'Targets';
end
if ~exist('ylabelText', 'var')
    ylabelText = 'Outputs';
end
if ~exist('classes', 'var')
    classes = getCategoryLabels();
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
set(gca, 'xaxisLocation', 'top');
set(gca, 'XTick', 1:numel(classes));
set(gca, 'YTick', 1:numel(classes));
set(gca, 'XTickLabel', classes);
set(gca, 'YTickLabel', classes);
% text
[xs, ys] = meshgrid(1:size(C, 1), 1:size(C, 2));
textString = arrayfun(@(i) sprintf('%.0f%%', i), 100 * C, ...
    'UniformOutput', false);
textColors = cell(size(C));
textColors((C  / max(C(:))) > 0.5) = {'w'};
textColors((C  / max(C(:))) <= 0.5) = {'k'};
if numel(classes) <= 2
    xs = xs - 0.15;
else
    xs = xs - 0.2;
end
for i = 1:numel(xs)
text(xs(i), ys(i), textString(i), 'Color', textColors{i});
end
end
