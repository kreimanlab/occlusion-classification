function [names, lineStyles, markers] = getModelLabels(labels)
if ~exist('labels', 'var')
    labels = 1:2;
end

names = cell(length(labels), 1);
names(labels == 1) = {'RNN'};
names(labels == 2) = {'Hopfield'};

lineStyles = cell(length(labels), 1);
lineStyles{labels == 1} = '--';
lineStyles{labels == 2} = ':';

markers = cell(length(labels), 1);
markers{labels == 1} = 's';
markers{labels == 2} = '*';
end
