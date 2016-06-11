function plotOverallHumanPerformance(categories, lineColor)
if ~exist('categories', 'var')
    categories = 1:5;
end
if ~exist('lineColor', 'var')
    lineColor = 'black';
end
humanResults = load('data/data_occlusion_klab325v2.mat');
humanResults = filterHumanData(humanResults.data);
humanResults = humanResults(ismember(humanResults.truth, categories), :);
performance = mean(humanResults.correct) * 100;
xlim = get(gca,'xlim');
line(xlim, [performance performance], 'Color', lineColor);
% text(xlim(1) + (xlim(2) - xlim(1)) / 10, performance + 5, 'human');
end
