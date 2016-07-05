function results = collapseResults(results)
%COLLAPSERESULTS merges different kfolds and orders the results by their
%testrows.
if iscell(results)
    results = vertcat(results{:});
end
[~, order] = sort(results.testrows, 'ascend');
results = results(order, :);
end
