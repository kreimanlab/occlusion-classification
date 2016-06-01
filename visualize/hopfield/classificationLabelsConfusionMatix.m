function classificationLabelsConfusionMatix(results, classifierName)
if iscell(results)
results = results{:};
end
results = results(strcmp(results.name, classifierName), :);
targets = results.truth;
outputs = results.response;

figure('Name', ['Classified labels of ' classifierName ' (qualitative)']);
plotQualitativeConfusionMatrix(targets, outputs);
figure('Name', ['Classified labels of ' classifierName ' (quantitative)']);
plotQuantitativeConfusionMatrix(targets, outputs);
end

function plotQualitativeConfusionMatrix(targets, outputs)
C = confusionmat(targets, outputs);
imshow(C' / max(C(:)), 'InitialMagnification', 10000);
colorbar;
colormap(flipud(gray));
end

function plotQuantitativeConfusionMatrix(targets, outputs)
targets = convertToOneHotEncoding(targets);
outputs = convertToOneHotEncoding(outputs);
plotconfusion(targets', outputs');
end

function oneHotEncoded = convertToOneHotEncoding(numericalEncoding)
classes = unique(numericalEncoding);
oneHotEncoded = zeros(length(numericalEncoding), length(classes));
for i = 1:length(classes)
    class = classes(i);
    rows = numericalEncoding == class;
    oneHotEncoded(rows, i) = 1;
end
end
