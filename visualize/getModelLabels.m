function [names, colors, lineStyles, markers] = getModelLabels(labels)
if ~exist('labels', 'var')
    labels = 1:5;
end

names = cell(length(labels), 1);
names(labels == 1) = {'RNN5'};
names(labels == 2) = {'RNNH'};
names(labels == 3) = {'RNN4'};
names(labels == 4) = {'RNN1'};
names(labels == 5) = {'fc7'};

colors = cell(length(labels), 1);
colors(labels == 1) = {'r'};
colors(labels == 2) = {'b'};
colors(labels == 3) = {'m'};
colors(labels == 4) = {'y'};
colors(labels == 5) = {'g'};

lineStyles = cell(length(labels), 1);
lineStyles{labels == 1} = '--';
lineStyles{labels == 2} = ':';
lineStyles{labels == 3} = '--';
lineStyles{labels == 4} = '--';
lineStyles{labels == 5} = '.';

markers = cell(length(labels), 1);
markers{labels == 1} = 's';
markers{labels == 2} = '*';
markers{labels == 3} = 'o';
markers{labels == 4} = '.';
markers{labels == 5} = 'x';
end
