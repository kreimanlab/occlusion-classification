function modelExperimentData = joinExperimentData(modelData)
if ~iscell(modelData)
    modelData = {modelData};
end

experimentData = load('data_occlusion_klab325v2.mat');
experimentData = dataset2table(experimentData.data);
experimentData.rows = (1:size(experimentData, 1))';
% delete human data
experimentData.responses = [];
experimentData.response_category = [];
experimentData.reaction_times = [];
experimentData.correct = [];
experimentData.subject = [];
experimentData.VBLsoa = [];
experimentData.masked = [];

modelExperimentData = cell(size(modelData));
for i = 1:numel(modelData)
    if ~istable(modelData{i})
        assert(isa(modelData{i}, 'dataset'));
        modelData{i} = dataset2table(modelData{i});
    end
    % get rid of redundant info
    modelData{i}.truth = [];
    modelData{i}.black = [];
    
    modelExperimentData{i} = join(modelData{i}, experimentData, ...
        'LeftKeys', 'testrows', 'RightKeys', 'rows');
end
end
