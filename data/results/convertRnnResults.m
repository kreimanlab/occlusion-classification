function results = convertRnnResults(file)
% convert the RNN results to a dataset with columns name, pres and correct.
if ~exist('file', 'var')
    file = ['data/results/classification/'...
        'RNN_correct_by_timestep_data_occlusion_klab325v2.xlsx'];
end
columnResults = dataset('XLSFile', file, 'Sheet', 'fc7_noRelu_trainorig');
columnResults.Properties.VarNames{1} = 'row';
% step 1: convert columns to model names
timesteps = 0:4;
indices = 2:6;
assert(length(indices) == length(timesteps));
for i = 1:length(indices)
    columnResults.Properties.VarNames{indices(i)} = ...
        ['RNN_t' num2str(timesteps(i))];
end
% step 2: convert columns to rows with name
data = load('data/data_occlusion_klab325v2.mat');
data = data.data;
modelNames = arrayfun(@(t) ['RNN_t' num2str(t)], timesteps, ...
    'UniformOutput', false);
for modelName = modelNames
    pres = data.pres(columnResults.row);
    correct = columnResults.(modelName{:});
    currentResults = struct2dataset(struct(...
        'name', {repmat(modelName, size(correct))}, ...
        'pres', pres, ...
        'correct', correct));
    if ~exist('results', 'var')
        results = currentResults;
    else
        results = [results; currentResults];
    end
end
end
