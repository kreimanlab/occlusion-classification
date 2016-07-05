function plotResponsesTruthConfusionMatrix(results)
%% prepare
if iscell(results)
results = collapseResults(results);
end
targets = results.truth;
if ismember('response', get(results, 'VarNames'))
    outputs = results.response;
else
    assert(ismember('response_category', get(results,'VarNames')));
    outputs = results.response_category;
end
%% plot
plotConfusionMatrix(targets, outputs, 'Truth', 'Response');
end
