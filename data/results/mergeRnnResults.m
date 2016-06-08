function results = mergeRnnResults(results, rnnResults)
if iscell(results)
    results = vertcat(results{:});
end
if iscell(rnnResults)
    rnnResults = vertcat(rnnResults{:});
end
results = table2dataset(outerjoin(...
    dataset2table(results), dataset2table(rnnResults), ...
    'MergeKeys', true...
    ));
end
