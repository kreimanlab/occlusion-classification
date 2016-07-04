function plotComparativeConfusionMatrix(results1, results2)
%% prepare
results1 = collapseResults(results1);
results2 = collapseResults(results2);
assert(numel(unique(results1.name)) == 1);
assert(numel(unique(results2.name)) == 1);
%% plot
targets = getPredicted(results1);
outputs = getPredicted(results2);
plotConfusionMatrix(targets, outputs);
end

function predicted = getPredicted(results)
if ismember('response', get(results, 'VarNames'))
    predicted = results.response;
else
    assert(ismember('response_category', get(results,'VarNames')));
    predicted = results.response_category;
end
end
