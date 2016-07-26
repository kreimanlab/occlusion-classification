function [names, lineStyles, markers, colors] = getModelLabels(labels)
if ~exist('labels', 'var')
    labels = 1:3;
end

names = cell(length(labels), 1);
names(labels == 1) = {'RNN5'};
names(labels == 2) = {'RNNH'};
names(labels == 3) = {'RNN1'};

lineStyles = cell(length(labels), 1);
lineStyles{labels == 1} = '--';
lineStyles{labels == 2} = ':';
lineStyles{labels == 3} = '.';

markers = cell(length(labels), 1);
markers{labels == 1} = 's';
markers{labels == 2} = '*';
markers{labels == 3} = 'o';

colors = cell(length(labels), 1);
colors(labels == 1) = {'r'};
colors(labels == 2) = {'b'};
colors(labels == 3) = {'y'};
end
