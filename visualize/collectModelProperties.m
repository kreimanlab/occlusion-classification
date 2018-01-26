function [abbreviatedNames, timestepNames, timesteps] = ...
    collectModelProperties(modelResults)
modelResults = collapseResults(modelResults);
modelPrefixes = {'rnn', 'hop', 'rnn4', 'rnn1', 'caffenet_relu7-libsvm'};
typeAbbreviations = getModelLabels();
uniqueNames = sort(unique(modelResults.name));
modelOccurrences = cell2mat(...
    cellfun(@(s) sum(cellfun(@(r) ~isempty(r), ...
    regexp(lower(uniqueNames), s, 'once'))), ...
    modelPrefixes, 'UniformOutput', false));
if ~any(modelOccurrences)
    warning('collapsing model to single timestep');
    abbreviatedNames = uniqueNames; timestepNames = abbreviatedNames;
    timesteps = 0;
    return;
end
abbreviatedNames = typeAbbreviations(logical(modelOccurrences));
rows = numel(abbreviatedNames);
cols = max(modelOccurrences);
timestepNames = cell(rows, cols);
timesteps = NaN(rows, cols);
modelTypes = find(logical(modelOccurrences));
for modelTypeIter = 1:length(modelTypes)
    modelType = modelTypes(modelTypeIter);
    typePrefix = modelPrefixes{modelType};
    typeTimestepNames = uniqueNames(~cellfun(@isempty, ...
        strfind(lower(uniqueNames), typePrefix)));
    typeTimesteps = cell2mat(cellfun(@(name) timestepFromName(name), ...
        typeTimestepNames, 'UniformOutput', false));
    [typeTimesteps, sortIndices] = sort(typeTimesteps, 'ascend');
    typeTimestepNames = typeTimestepNames(sortIndices);
    timestepNames(modelTypeIter, 1:length(typeTimestepNames)) = typeTimestepNames;
    timesteps(modelTypeIter, 1:length(typeTimesteps)) = typeTimesteps;
end
% shift RNN one to the right if -1 (unpolarized) in hop
if(rows == 2 && all(timesteps(2, 1:2) == [-1, 0]) && isnan(timesteps(1, end)))
    timesteps(1, :) = [NaN, timesteps(1, 1:end-1)];
    timestepNames(1, :) = [{[]}, timestepNames(1, 1:end-1)];
end
end

function timestep = timestepFromName(classifierName)
token = regexp(classifierName, '[_\-]t(?:imestep)?\-?([0-9]+)', 'tokens');
if isempty(token)
    timestep = 0;
else
    timestep = str2double(token{end}{1});
end
end
