function [names, lineStyles, markers] = getModelLabels(labels)
if ~exist('labels', 'var')
    labels = 1:3;
end

names = cell(length(labels), 1);
names(labels == 1) = {'RNN'};
names(labels == 2) = {'Hopfield'};
names(labels == 3) = {'RNN-train1cat'};

lineStyles = cell(length(labels), 1);
lineStyles{labels == 1} = '--';
lineStyles{labels == 2} = ':';
lineStyles{labels == 3} = '.';

markers = cell(length(labels), 1);
markers{labels == 1} = 's';
markers{labels == 2} = '*';
markers{labels == 3} = 'o';
end
