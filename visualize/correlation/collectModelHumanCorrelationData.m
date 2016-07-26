function correlationData = collectModelHumanCorrelationData(modelResults)
%COLLECTMODELHUMANCORRELATIONDATA Collect correlations between model and
%human
modelResults = collapseResults(modelResults);

numPartitions = 20;
humanResults = load('data/data_occlusion_klab325v2.mat');
[humanResults, relevantRows] = filterHumanData(humanResults.data, true);
[rowPartitions1, rowPartitions2] = partitionTrials(humanResults, numPartitions);
presIds = unique(humanResults.pres)';

% human
humanCorrectHalfs = NaN(numel(rowPartitions1), length(presIds), 2);
humanCorrect = NaN(length(presIds), 1);
humanHumanCorrelations = NaN(size(rowPartitions1));
for i = 1:size(rowPartitions1, 1)
    rows1 = rowPartitions1{i};
    rows2 = rowPartitions2{i};
    for pres = presIds
        humanCorrect(pres) = mean(humanResults.correct(...
            humanResults.pres == pres));
        half1 = humanResults.correct(...
            intersect(rows1, find(humanResults.pres == pres)));
        half2 = humanResults.correct(...
            intersect(rows2, find(humanResults.pres == pres)));
        assert(~isempty(half1));
        assert(~isempty(half2));
        humanCorrectHalfs(i, pres, 1) = mean(half1);
        humanCorrectHalfs(i, pres, 2) = mean(half2);
    end
    humanHumanCorrelations(i) = corr(...
        humanCorrectHalfs(i, :, 1)', humanCorrectHalfs(i, :, 2)');
end
% model
[modelNames, modelTimestepNames, timesteps] = ...
    collectModelProperties(modelResults);
modelHumanCorrelations = NaN([numel(rowPartitions1), size(modelTimestepNames)]);
modelCorrect = NaN([length(presIds), size(modelTimestepNames)]); % pres x type x model
for model = 1:size(modelTimestepNames, 1)
    for timeIter = 1:size(modelTimestepNames, 2)
        if isempty(modelTimestepNames{model, timeIter})
            continue;
        end
        currentModelResults = modelResults(strcmp(modelResults.name, ...
            modelTimestepNames{model, timeIter}) & ...
            ismember(modelResults.testrows, find(relevantRows)), :);
        assert(~isempty(currentModelResults));
        % correct
        for pres = presIds
            currentPresResults = currentModelResults(...
                currentModelResults.pres == pres, :);
            assert(~isempty(currentPresResults));
            modelCorrect(pres, model, timeIter) = ...
                mean(currentPresResults.correct);
        end
        % correlation
        for i = 1:size(rowPartitions1, 1)
            rows1 = rowPartitions2{i};
            modelCorrectHalf1 = NaN(numel(presIds), 1);
            for pres = presIds
                currentPresResults = currentModelResults.correct(...
                    ismember(currentModelResults.testrows, rows1) & ...
                    currentModelResults.pres == pres);
                assert(~isempty(currentPresResults));
                modelCorrectHalf1(pres) = mean(currentPresResults);
            end
            modelHumanCorrelations(i, model, timeIter) = corr(...
                modelCorrectHalf1, humanCorrectHalfs(i, :, 2)');
        end
    end
end

correlationData = CorrelationData(presIds, ...
    humanResults, humanCorrect, humanCorrectHalfs, ...
    modelNames, modelTimestepNames, timesteps, ...
    modelCorrect, ...
    humanHumanCorrelations, modelHumanCorrelations);
