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
fc7Results = collapseResults(fc7Results);
rnn5Results = changeResults(filterResults(rnnTimes.results, ...
    @(r) strcmp(r.name, 'RNN_features_fc7_noRelu_t4-libsvmccv')), ...
    'name', @(r) repmat({'RNN5'}, [size(r, 1), 1]));
rnn5Results = collapseResults(rnn5Results);
% hop
hopResults = load('data/results/classification/hoptimes-trainAll.mat');
hopResults = changeResults(filterResults(hopResults.results, ...
    @(r) strcmp(r.name, 'caffenet_fc7-bipolar0-hop_t256-libsvmccv')), ...
    'name', @(r) repmat({'RNNH'}, [size(r, 1), 1]));
hopResults = collapseResults(hopResults);
% RNN1
rnn1Results = load('data/results/classification/train1cat/excludeTrainCategory/merged.mat');
rnn1Results = changeResults(filterResults(rnn1Results.results, ...
    @(r) cellfun(@(m) ~isempty(m), ...
    regexp(r.name, 'train1cat/split-[0-5]_t\-4\/features-libsvmccv'))), ...
    'name', @(r) repmat({'RNN1'}, [size(r, 1), 1]));
rnn1Results = collapseResults(rnn1Results);

%% comparisons
pairs = {hopResults, fc7Results; ...
    rnn5Results, humanResults; ...
    rnn1Results, fc7Results};
for row = 1:size(pairs, 1)
    results1 = pairs{row, 1};
    results2 = pairs{row, 2};
    name1 = unique(results1.name);
    name2 = unique(results2.name);
    correct1 = results1.correct;
    correct2 = results2.correct;
    overall1 = getAccuracies(results1);
    overall2 = getAccuracies(results2);
    [h, p] = chi2(overall1, overall2);
    fprintf(['[6C] overall %s: %.0f%% +- %.2f%%, != %s (%.2f%%): ', ...
        'h=%d, p=%d\n'], ...
        name1{:}, 100 * mean(correct1), 100 * stderrmean(correct1), ...
        name2{:}, 100 * mean(correct2), h, p);
end
end

function accuracies = getAccuracies(results)
classifierName = unique(results.name);
assert(numel(classifierName) == 1);
percentsBlack = [65:5:95, 99];
accuracies = NaN(size(percentsBlack));
for iBlack = 1:length(percentsBlack)
    [blackMin, blackMax] = ...
        getPercentBlackRange(percentsBlack, iBlack);
    accuracies(iBlack) = collectAccuracies({results}, ...
        blackMin, blackMax, classifierName);
end
end
