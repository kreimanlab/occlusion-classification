function results = changeResults(results, variable, provide)
%CHANGERESULTS Summary of this function goes here
%   Detailed explanation goes here
if ~iscell(results)
    results = {results};
end
for i = 1:numel(results)
    r = results{i};
    if isempty(provide)
        r.(variable) = [];  % have to delete this way because Matlab sucks
    else
        r.(variable) = provide(r);
    end
    results{i} = r;
end
end
