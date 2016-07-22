function results = changeResults(results, variable, provide)
%CHANGERESULTS Summary of this function goes here
%   Detailed explanation goes here
if ~iscell(results)
    results = {results};
end
for i = 1:numel(results)
    r = results{i};
    r.(variable) = provide(r);
    results{i} = r;
end
end
