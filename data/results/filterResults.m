function filteredResults = filterResults(results, filterFnc)
if ~iscell(results)
    results = {results};
end
if ~exist('filterFnc', 'var')
    filterFnc = @(data) ones(size(data, 1), 1);
end

filteredResults = cell(length(results), 1);
for i = 1:length(filteredResults)
    res = results{i};
    filteredResults{i} = res(filterFnc(res), :);
end
end
