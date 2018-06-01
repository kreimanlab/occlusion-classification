function [modelHumanCorrelationsPerCategory, humanTimesteps, modelTimesteps] = ...
    collectModelHumanMaskingCorrelationData(hopMaskingResults)
numPartitions = 20;
humanResults = load('data/data_occlusion_klab325v2.mat');
[humanResults, relevantRows] = filterHumanData(humanResults.data, true, true);
[rowPartitions1, rowPartitions2] = partitionTrials(humanResults, numPartitions);
presIds = unique(humanResults.pres)';
categories = getCategoryLabels();
presPerCategory = 60;
categoriesPres = NaN(numel(categories), presPerCategory);
for category = 1:numel(categories)
    pres = unique(humanResults.pres(humanResults.truth == category));
    categoriesPres(category, :) = pres;
end

%% human
humanTimesteps = unique(humanResults.soa);
humanCorrect = NaN(numel(humanTimesteps), length(presIds));
humanCorrectHalfs = NaN(numel(humanTimesteps), numel(rowPartitions1), length(presIds), 2);
humanCorrectPerCategory = NaN(numel(humanTimesteps), numel(categories), presPerCategory);
humanCorrectHalfsPerCategory = NaN(numel(humanTimesteps), numel(rowPartitions1), ...
    numel(categories), presPerCategory, 2);
humanHumanCorrelations = NaN(numel(humanTimesteps), numel(rowPartitions1));
humanHumanCorrelationsPerCategory = NaN(numel(humanTimesteps), numel(rowPartitions1), numel(categories));
for timeIter = 1:numel(humanTimesteps)
    t = humanTimesteps(timeIter);
    fprintf('human t=%d, %d/%d\n', t, timeIter, numel(humanTimesteps));
    humanTimeResults = humanResults(humanResults.soa == t, :);
    % correct per pres
    for pres = presIds
        humanCorrect(timeIter, pres) = mean(humanTimeResults.correct(...
            humanTimeResults.pres == pres));
        for category = 1:numel(categories)
            humanCorrectPerCategory(timeIter, category, :) = ...
                humanCorrect(timeIter, categoriesPres(category, :));
        end
    end
    % partitioned
    for i = 1:size(rowPartitions1, 1)
        rows1 = rowPartitions1{i};
        rows2 = rowPartitions2{i};
        correctHalfs1 = [];
        correctHalfs2 = [];
        % all categories
        for pres = presIds
            half1 = humanTimeResults.correct(...
                intersect(rows1, find(humanTimeResults.pres == pres)));
            half2 = humanTimeResults.correct(...
                intersect(rows2, find(humanTimeResults.pres == pres)));
            humanCorrectHalfs(timeIter, i, pres, 1) = mean(half1);
            humanCorrectHalfs(timeIter, i, pres, 2) = mean(half2);
        end
        halfNonNaNRows = ~isnan(humanCorrectHalfs(timeIter, i, :, 1)) & ~isnan(humanCorrectHalfs(timeIter, i, :, 2));
        half1 = humanCorrectHalfs(timeIter, i, halfNonNaNRows, 1);
        half2 = humanCorrectHalfs(timeIter, i, halfNonNaNRows, 2);
        humanHumanCorrelations(timeIter, i) = corr(squeeze(half1), squeeze(half2));
        % per category
        for category = 1:numel(categories)
            for half = 1:2
                humanCorrectHalfsPerCategory(timeIter, i, category, :, half) = ...
                    humanCorrectHalfs(timeIter, i, categoriesPres(category, :), half);
            end
            halfNonNaNRows = ~isnan(humanCorrectHalfsPerCategory(timeIter, i, category, :, 1)) ...
                & ~isnan(humanCorrectHalfsPerCategory(timeIter, i, category, :, 2));
            half1 = humanCorrectHalfsPerCategory(timeIter, i, category, halfNonNaNRows, 1);
            half2 = humanCorrectHalfsPerCategory(timeIter, i, category, halfNonNaNRows, 2);
            humanHumanCorrelationsPerCategory(timeIter, i, category) = ...
                corr(squeeze(half1), squeeze(half2));
        end
    end
end


%% model
timeResultsHop = load('data/results/classification/hoptimes-trainAll.mat');
timeResultsHop = timeResultsHop.results;
hopResults256 = filterResults(timeResultsHop, ...
    @(r) strcmp(r.name, 'caffenet_fc7-bipolar0-hop_t256-libsvmccv'));
hopMaskingResults = filterResults(hopMaskingResults, ...
    @(r) ismember(r.testrows, find(relevantRows)));
experimentData = load('data_occlusion_klab325v2.mat');
experimentData = experimentData.data;
modelTimesteps = [2, 4, 8, 16, 32, 64, 256];
modelCorrect = NaN([length(presIds), numel(modelTimesteps)]); % pres x model
modelCorrectPerCategory = NaN([numel(categories), numel(modelTimesteps), ...
    presPerCategory]); % partition x category x model x time x pres
modelHumanCorrelationsPerCategory = NaN([numel(humanTimesteps), numel(modelTimesteps), ...
    numel(categories)]); % timesteps human x timesteps model x categories
for timeIterModel = 1:numel(modelTimesteps)
    %% collect model
    t = modelTimesteps(timeIterModel);
    if t == 256 % no mask
        maskingResults = hopResults256;
    else
        if t == 0
            pattern = '^sumFeatures_alexnet-relu7-bipolar0_alexnet-relu7-masked-bipolar0-hop_t256-libsvmccv$';
        else
            pattern = ['^.*.bipolar0-hop_t', num2str(t), '_.*-hop_t256-libsvmccv$'];
        end
        maskingResults = filterResults(hopMaskingResults, ...
            @(r) cellfun(@(i) ~isempty(i), regexp(r.name, pattern)));
        maskingResults = joinExperimentData(maskingResults, experimentData);
    end
    maskingResults = collapseResults(maskingResults);
    
    % correct overall
    for pres = presIds
        currentPresResults = maskingResults(...
            maskingResults.pres == pres, :);
        assert(~isempty(currentPresResults));
        modelCorrect(pres, timeIterModel) = ...
            mean(currentPresResults.correct);
    end
    % correlation per category
    for category = 1:numel(categories)
        modelCorrectPerCategory(category, timeIterModel, :) = ...
            modelCorrect(categoriesPres(category, :), timeIterModel);
        for timeIterHuman = 1:numel(humanTimesteps)
            modelValues = modelCorrect(categoriesPres(category, :), timeIterModel);
            humanValues = squeeze(humanCorrectPerCategory(timeIterHuman, category, :));
            nonNaNRows = ~isnan(humanValues);
            modelHumanCorrelationsPerCategory(timeIterHuman, timeIterModel, category) = ...
                corr(modelValues(nonNaNRows), humanValues(nonNaNRows));
        end
    end
end
end

