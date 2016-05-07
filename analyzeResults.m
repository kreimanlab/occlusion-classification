function [matched, accuracy] = analyzeResults(predictedLabels, realLabels)
assert(length(predictedLabels) == length(realLabels));
numLabels = length(realLabels);
matched = zeros(numLabels, 1);
correct = 0;
for i=1:numLabels
    if predictedLabels(i) == realLabels(i)
        matched(i) = 1;
        correct = correct + 1;
    else
        matched(i)= 0;
    end
end
accuracy = correct / numLabels;
