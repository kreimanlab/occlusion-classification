function correlationData = collectModelHumanCorrelationData(modelResults)
%COLLECTMODELHUMANCORRELATIONDATA Collect correlations between model and
%human

if iscell(modelResults)
    modelResults = vertcat(modelResults{:});
end

presIds = 1:300;
% human
humanResults = load('data/data_occlusion_klab325v2.mat');
humanResults = humanResults.data;
humanResults = humanResults(...
    humanResults.occluded == 1 & ...
    humanResults.masked == 0, :);
subjects = unique(humanResults.subject);
idx1 = subjects(randperm(length(subjects), round(length(subjects) / 2)));
idx2 = setdiff(subjects, idx1);
humanCorrectHalfs = NaN(length(presIds), 2);
humanCorrect = NaN(length(presIds), 1);
for pres = presIds
    relevantResults = humanResults(humanResults.pres == pres, :);
    humanCorrectHalfs(pres, 1) = mean(relevantResults.correct(...
        ismember(relevantResults.subject, idx1)));
    humanCorrectHalfs(pres, 2) = mean(relevantResults.correct(...
        ismember(relevantResults.subject, idx2)));
    humanCorrect(pres) = mean(relevantResults.correct);
end
humanHumanCorrelation = corr(...
    humanCorrectHalfs(:,1), humanCorrectHalfs(:,2));
% model
[modelNames, modelTimestepNames, timesteps] = ...
    collectModelProperties(modelResults);
modelHumanCorrelations = NaN(size(modelTimestepNames));
modelCorrect = NaN([length(presIds), size(modelTimestepNames)]); % pres x type x model
for model = 1:numel(modelTimestepNames)
    if isempty(modelTimestepNames{model})
        continue;
    end
    for pres = presIds
        relevantResults = modelResults(...
            strcmp(modelTimestepNames{model}, modelResults.name) & ...
            modelResults.pres == pres, :);
        assert(~isempty(relevantResults));
        modelCorrect(pres, model) = mean(relevantResults.correct);
    end
    modelHumanCorrelations(model) = corr(...
        modelCorrect(:, model), humanCorrect(:));
end

correlationData = CorrelationData(presIds, ...
    humanResults, humanCorrect, humanCorrectHalfs, ...
    modelNames, modelTimestepNames, timesteps, modelCorrect, ...
    humanHumanCorrelation, modelHumanCorrelations);
