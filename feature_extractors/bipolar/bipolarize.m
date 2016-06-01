function bipolarized = bipolarize(x, threshold, negative, positive)
% x(x >  threshold) -> positive;
% x(x <= threshold) -> negative;
if ~exist('negative', 'var')
    negative = -1;
end
if ~exist('positive', 'var')
    positive = +1;
end
positiveX = x > threshold; % avoid side-effects due to changed values in second pass
x(x <= threshold) = negative;
x(positiveX) = positive;
bipolarized = x;
end

