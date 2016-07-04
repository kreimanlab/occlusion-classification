function plotResponsesTruthConfusionMatrix(results)
%% prepare
if iscell(results)
results = vertcat(results{:});
end
if exist('classifierName', 'var')
    results = results(strcmp(results.name, classifierName), :);
    nameSuffix = [' of ' classifierName];
elseif any(strcmp('name', get(results, 'VarNames'))) % work on all results
    nameSuffix = unique(results.name);
    assert(numel(nameSuffix) == 1);
    nameSuffix = nameSuffix{1};
else % human
    nameSuffix = '';
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
