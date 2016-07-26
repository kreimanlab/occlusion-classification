function standardErrorOfTheMean = stderrmean(X, dim)
if ~exist('dim', 'var')
    dim = 1;
end
standardErrorOfTheMean = std(X, 0, dim) / sqrt(size(X, dim));
end
