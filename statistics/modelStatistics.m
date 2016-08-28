function modelStatistics()
%% data
% human
humanResults = load('data/data_occlusion_klab325v2.mat');
humanResults = filterHumanData(humanResults.data);
humanResults.name = repmat({'human'}, size(humanResults, 1), 1);
% fc7 + RNN5_t4
rnnTimes = load('data/results/classification/rnntimes.mat');
fc7Results = changeResults(filterResults(rnnTimes.results, ...
    @(r) strcmp(r.name, 'RNN_features_fc7_noRelu_t0-libsvmccv')), ...
    'name', @(r) repmat({'fc7'}, [size(r, 1), 1]));
rnn5Results = changeResults(filterResults(rnnTimes.results, ...
    @(r) strcmp(r.name, 'RNN_features_fc7_noRelu_t4-libsvmccv')), ...
    'name', @(r) repmat({'RNN5'}, [size(r, 1), 1]));
% hop
hopResults = load('data/results/classification/hoptimes-trainAll.mat');
hopResults = changeResults(filterResults(hopResults.results, ...
    @(r) strcmp(r.name, 'caffenet_fc7-bipolar0-hop_t256-libsvmccv')), ...
    'name', @(r) repmat({'RNNH'}, [size(r, 1), 1]));
% RNN1
rnn1Results = load('data/results/classification/train1cat/excludeTrainCategory/merged.mat');
rnn1Results = changeResults(filterResults(rnn1Results.results, ...
    @(r) cellfun(@(m) ~isempty(m), ...
    regexp(r.name, 'train1cat/split-[0-5]_t\-4\/features-libsvmccv'))), ...
    'name', @(r) repmat({'RNN1'}, [size(r, 1), 1]));
% RNN-masked
rnnMaskedResults = getRnnMaskedResults();

%% comparisons
pairs = {hopResults, fc7Results; ...
    rnn5Results, {humanResults}; ...
    rnn1Results, fc7Results};
for i = 1:numel(rnnMaskedResults)
    pairs(end + 1, :) = {rnnMaskedResults{i}, rnn5Results};
end
for row = 1:size(pairs, 1)
    results1 = pairs{row, 1};
    results2 = pairs{row, 2};
    name1 = unique(results1{1}.name);
    name2 = unique(results2{1}.name);
    accuracies1 = getAccuracies(results1);
    accuracies2 = getAccuracies(results2);
    assert(size(accuracies1, 2) == numel(results1));
    meanAccuracies1 = mean(accuracies1, 2);
    meanAccuracies2 = mean(accuracies2, 2);
    [h, p] = chi2(meanAccuracies1, meanAccuracies2);
    fprintf(['[6C] overall %5s: %.0f%% +- %.2f%%, != %5s (%.2f%% +- %.2f%%): ', ...
        'h=%d, p=%d\n'], ...
        name1{:}, mean(meanAccuracies1), mean(stderrmean(accuracies1, ...
        ...% last non-singleton dimension
        find(size(accuracies1) > 1, 1, 'last'))), ...
        name2{:}, mean(meanAccuracies2), mean(stderrmean(accuracies2, ...
        ...% last non-singleton dimension
        find(size(accuracies2) > 1, 1, 'last'))), ...
        h, p);
end
end

function accuracies = getAccuracies(results)
classifierName = unique(results{1}.name);
assert(numel(classifierName) == 1);
percentsBlack = [65:5:95, 99];
accuracies = NaN([numel(percentsBlack), numel(results)]);
for iBlack = 1:length(percentsBlack)
    [blackMin, blackMax] = ...
        getPercentBlackRange(percentsBlack, iBlack);
    accuracies(iBlack, :) = collectAccuracies(results, ...
        blackMin, blackMax, classifierName);
end
end

function rnnMaskedResults = getRnnMaskedResults()
results = load('data/results/classification/rnn-masking.mat');
results = results.results;
masks = 0:5;
timestep = 4;
rnnMaskedResults = cell(size(masks));
for maskIter = 1:numel(masks)
    mask = masks(maskIter);
    currentResults = filterResults(results, ...
        @(r) cell2mat(cellfun(@(s) ~isempty(s), ...
        strfind(r.name, sprintf('mask%d-rnn-t%d', mask, timestep)), ...
        'UniformOutput', false)));
    rnnMaskedResults{maskIter} = joinExperimentData(currentResults);
end
end
