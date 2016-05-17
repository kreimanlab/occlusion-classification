function labelNames = stringifyLabels(labels)
labelNames = cell(length(labels), 1);
labelNames(labels == 1) = {'Animals'};
labelNames(labels == 2) = {'Chairs'};
labelNames(labels == 3) = {'Faces'};
labelNames(labels == 4) = {'Fruits'};
labelNames(labels == 5) = {'Vehicles'};
end
