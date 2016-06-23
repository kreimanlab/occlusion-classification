function plotHumanPerformance(percentsBlack, dataset)
if ~exist('percentsBlack', 'var') || isempty(percentsBlack)
    percentsBlack = [65:5:95, 99];
end
if ~exist('dataset', 'var')
    dataset = load('data/data_occlusion_klab325v2.mat');
    dataset = dataset.data;
end

percentsBlack = sort(percentsBlack);
dataset = filterHumanData(dataset);
[meanValues, standardErrorOfTheMean, ...
    percentBlackCenters, percentBlackRanges] = ...
    statsAcrossAll(dataset, percentsBlack);
errorbarxy(permute(100 - percentBlackCenters, [2 1]), ...
    meanValues, percentBlackRanges(:, 1), percentBlackRanges(:, 2), ...
    standardErrorOfTheMean, standardErrorOfTheMean, 'blacko-');
text(100 - percentsBlack(1) + 1, meanValues(1), 'human');
end

function [meanValues, standardErrorOfTheMean, ...
    percentBlackCenters, percentBlackRanges] = ...
    statsAcrossAll(dataset, percentsBlack)
% averages across all subjects at once
meanValues = NaN(length(percentsBlack) - 1, 1);
standardErrorOfTheMean = NaN(length(percentsBlack)-1, 1);
percentBlackCenters = NaN(size(percentsBlack));
percentBlackRanges = NaN([numel(percentsBlack), 2]);
for iBlack = 1:length(percentsBlack)
    [blackMin, blackMax, blackCenter, rangeLeft, rangeRight] = ...
        getPercentBlackRange(percentsBlack, iBlack);
    percentBlackCenters(iBlack) = blackCenter;
    percentBlackRanges(iBlack, 1) = rangeLeft;
    percentBlackRanges(iBlack, 2) = rangeRight;
    currentData = dataset(...
        dataset.black >= blackMin & dataset.black < blackMax, :);
    meanValues(iBlack) = 100 * mean(currentData.correct);
    standardErrorOfTheMean(iBlack) = 100 * ...
        std(currentData.correct) / sqrt(length(currentData));
end
end
