function [matched, accuracy] = analyzeResults(predictedLabels, realLabels)
assert(length(predictedLabels) == length(realLabels));
numLabels = length(realLabels);
matched = zeros(numLabels, 1);
resultsDescription = cell(numLabels,1);
correct = 0;
for i=1:numLabels
    if predictedLabels(i) == realLabels(i)
        matched(i) = 1;
        resultsDescription{i} = 'OK';
        correct = correct+1;
    else
        matched(i)= 0;
        resultsDescription{i} = 'ERR';
    end
end
zippedResults=[resultsDescription(:)';...
    num2cell(predictedLabels(:)');...
    num2cell(realLabels(:)')];
fprintf('[%s] Prediction: %d | Real: %d\n', zippedResults{:});
accuracy = correct / numLabels;
fprintf('%d/%d (%.2f%%)\n', correct, numLabels, 100.0 * accuracy);
