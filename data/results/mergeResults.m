function mergedResults = mergeResults(results1, results2)
assert(length(results1) == length(results2));
mergedResults = cell(length(results1), 1);
for i = 1:length(mergedResults)
    r1 = results1{i}; r2 = results2{i};
    mergedResults{i} = [r1; r2];
end
end
