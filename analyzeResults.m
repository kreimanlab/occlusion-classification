function [correct, accuracy] = analyzeResults(predictedLabels, realLabels)
assert(isequal(size(predictedLabels), size(realLabels)));
correct = NaN(size(realLabels));
correct(predictedLabels == realLabels) = 1;
correct(predictedLabels ~= realLabels) = 0;
accuracy = mean(correct);
