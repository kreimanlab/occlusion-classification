function [names, colors] = getCategoryLabels(labels)
if ~exist('labels', 'var')
    labels = 1:5;
end

names = cell(length(labels), 1);
names(labels == 1) = {'Animals'};
names(labels == 2) = {'Chairs'};
names(labels == 3) = {'Faces'};
names(labels == 4) = {'Fruits'};
names(labels == 5) = {'Vehicles'};

colors = cell(length(labels), 1);
colors{labels == 1} = 'r';
colors{labels == 2} = 'b';
colors{labels == 3} = 'g';
colors{labels == 4} = 'y'; %[1 0.9020 0.1608];
colors{labels == 5} = 'm';
end
