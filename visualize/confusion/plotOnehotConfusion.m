function plotOnehotConfusion(targets, outputs)
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
