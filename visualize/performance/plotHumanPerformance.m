function plotHumanPerformance(percentsBlack)
if ~exist('percentsBlack', 'var')
    percentsBlack = [65:5:95, 99];
end

percentsBlack = sort(percentsBlack);
dataset = load('data/data_occlusion_klab325v2.mat');
dataset = dataset.data;
dataset = filterHumanData(dataset);
[meanValues, standardErrorOfTheMean] = statsAcrossAll(dataset, percentsBlack);
errorbar(permute(100 - percentsBlack, [2 1]), ...
    meanValues, standardErrorOfTheMean, 'blacko-');
text(100 - percentsBlack(1) + 1, meanValues(1), 'human');
end

function [meanValues, standardErrorOfTheMean] = ...
    statsAcrossAll(dataset, percentsBlack)
% averages across all subjects at once
meanValues = NaN(length(percentsBlack)-1, 1);
standardErrorOfTheMean = NaN(length(percentsBlack)-1, 1);
for iPb = 1:length(percentsBlack)
    currentData = dataset(...
        dataset.black >= percentsBlack(iPb), :);
    if iPb < length(percentsBlack)
        currentData = currentData(...
            currentData.black < percentsBlack(iPb + 1), :);
    end
    meanValues(iPb) = 100 * mean(currentData.correct);
    standardErrorOfTheMean(iPb) = 100 * ...
        std(currentData.correct) / sqrt(length(currentData));
end
end

function [meanValues, standardErrorOfTheMean] = ...
    statsAcrossSubjects(dataset, percentsBlack)
% averages across each subject individually
subjects = unique(dataset.subject);
accuracies = zeros(length(percentsBlack)-1, length(subjects));
for iPb = 1:length(percentsBlack)
    for iS = 1:length(subjects)
        currentData = dataset(...
            dataset.subject == subjects(iS) & ...
            dataset.black >= percentsBlack(iPb), :);
        if iPb < length(percentsBlack)
            currentData = currentData(...
                currentData.black < percentsBlack(iPb + 1), :);
        end
        accuracies(iPb, iS) = 100 * ...
            mean(currentData.correct);
    end
end
meanValues = mean(accuracies, 2, 'omitnan');
standardErrorOfTheMean = std(accuracies, 0, 2, 'omitnan') / ...
    sqrt(size(accuracies, 2));
end
