function [h, p] = chi2(O, E)
assert(numel(O) == numel(E));
score = sum(((O - E) .^ 2) ./ E);
degreesOfFreedom = (2 - 1) * (numel(O) - 1); % vars-1 * observations-1
p = chi2pdf(score, degreesOfFreedom);
h = p <= 0.05;
end
