function modelExperimentData = joinExperimentData(modelData, experimentData)
if ~iscell(modelData)
    modelData = {modelData};
end
if ~exist('experimentData', 'var')
    experimentData = load('data_occlusion_klab325v2.mat');
end

experimentData = dataset2table(experimentData);
experimentData.rows = (1:size(experimentData, 1))';
% delete human data
experimentData = deleteVars(experimentData, {'responses', 'response_category', ...
    'reaction_times', 'correct', 'subject', 'VBLsoa', 'masked'});

modelExperimentData = cell(size(modelData));
for i = 1:numel(modelData)
    if ~istable(modelData{i})
        assert(isa(modelData{i}, 'dataset'));
        modelData{i} = dataset2table(modelData{i});
    end
    % get rid of redundant info
    if ismember('truth', modelData{i}.Properties.VariableNames)
        modelData{i}.truth = [];
    end
    if ismember('black', modelData{i}.Properties.VariableNames)
        modelData{i}.black = [];
    end
    
    modelExperimentData{i} = join(modelData{i}, experimentData, ...
        'LeftKeys', 'testrows', 'RightKeys', 'rows');
end
end

function data = deleteVars(data, vars)
for varIter = 1:numel(vars)
    var = vars{varIter};
    if ismember(var, data.Properties.VariableNames)
        data.(var) = [];
    end
end
end
