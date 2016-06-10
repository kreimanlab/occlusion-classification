function [labelNames, colors] = getLabelDescriptions(labels)
if ~exist('labels', 'var')
    labels = 1:5;
end

labelNames = cell(length(labels), 1);
labelNames(labels == 1) = {'Animals'};
labelNames(labels == 2) = {'Chairs'};
labelNames(labels == 3) = {'Faces'};
labelNames(labels == 4) = {'Fruits'};
labelNames(labels == 5) = {'Vehicles'};

colors = cell(length(labels), 1);
colors{labels == 1} = 'r';
colors{labels == 2} = 'b';
colors{labels == 3} = 'g';
colors{labels == 4} = [1 0.9020 0.1608];
colors{labels == 5} = 'm';
end
