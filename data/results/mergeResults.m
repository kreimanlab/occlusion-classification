function results = mergeResults(varargin)
for resIter = 1:numel(varargin)
    res = varargin{resIter};
    if ~iscell(res)
        res = {res};
    end
    if ~exist('results', 'var')
        results = res;
    else
        assert(numel(results) == numel(res));
        for i = 1:numel(results)
            r1 = results{i}; r2 = res{i};
            if isa(r1, 'dataset') r1 = dataset2table(r1); end
            if isa(r2, 'dataset') r2 = dataset2table(r2); end
            results{i} = table2dataset(outerjoin(r1, r2, ...
                'MergeKeys', true));
        end
    end
end
