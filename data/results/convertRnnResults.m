function results = convertRnnResults(file)
% retrieve the RNN results.
if ~exist('file', 'var')
    file = ['data/results/classification/'...
        'data_occlusion_klab325v2_with_models.mat'];
end
data = load(file);
data = data.data;
timesteps = 0:6;
for t = timesteps
    name = sprintf('RNN_fc7_noRelu_t%d', t);
    correct = data.([name, '_trainorig_correct']);
    responses = data.([name, '_trainorig_response_category']);
    currentResults = struct2dataset(struct(...
        'name', {repmat({name}, size(correct))}, ...
        'pres', data.pres, ...
        'black', data.black, ...
        'truth', data.truth, ...
        'correct', correct, ...
        'response', responses, ...
        'testrows', (1:numel(correct))'));
    if ~exist('results', 'var')
        results = currentResults;
    else
        results = [results; currentResults];
    end
end
