function modelStatistics()
%% data
% human
humanResults = load('data/data_occlusion_klab325v2.mat');
humanResults = filterHumanData(humanResults.data);
humanResults.name = repmat({'Human'}, size(humanResults, 1), 1);
% fc7 + RNN5_t4
rnnTimes = load('data/results/classification/rnntimes.mat');
fc7Results = filterResults(rnnTimes.results, ...
    @(r) strcmp(r.name, 'RNN_features_fc7_noRelu_t0-libsvmccv'));
fc7Results = collapseResults(fc7Results);
rnnResults = filterResults(rnnTimes.results, ...
    @(r) strcmp(r.name, 'RNN_features_fc7_noRelu_t4-libsvmccv'));
rnnResults = collapseResults(rnnResults);
% hop
hopResults = load('data/results/classification/hoptimes-trainAll.mat');
hopResults = filterResults(hopResults.results, ...
    @(r) strcmp(r.name, 'caffenet_fc7-bipolar0-hop_t256-libsvmccv'));
hopResults = collapseResults(hopResults);

%% overall vs fc7
hopOverall = getAccuracies(hopResults);
fc7Overall = getAccuracies(fc7Results);
[h, p] = ttest2(hopOverall, fc7Overall);
assert(h == 1);
fprintf('[6C] overall hop: %.0f%% +- %.0f%%, != fc7: p=%d\n', ...
    100 * mean(hopOverall), 100 * stderrmean(hopOverall), p);

%% RNN5 vs human
rnnOverall = getAccuracies(rnnResults);
humanOverall = getAccuracies(humanResults);
[h, p] = ttest2(rnnOverall, humanOverall);
assert(h == 0);
fprintf('[6C] overall RNN5 (%.0f%%) == human (%.0f%%): p=%.2f\n', ...
    mean(rnnOverall), mean(humanOverall), p);

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
