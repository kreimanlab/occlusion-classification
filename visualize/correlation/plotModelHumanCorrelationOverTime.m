function plotModelHumanCorrelationOverTime(modelResults)
if iscell(modelResults)
    modelResults = vertcat(modelResults{:});
end

presIds = 1:300;
%% Collect data
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
for i = 1:size(humanCorrectHalfs,1)
    pres = presIds(i);
    relevantResults = humanResults(humanResults.pres == pres, :);
    humanCorrectHalfs(i,1) = mean(relevantResults.correct(...
        ismember(relevantResults.subject, idx1)));
    humanCorrectHalfs(i,2) = mean(relevantResults.correct(...
        ismember(relevantResults.subject, idx2)));
    humanCorrect(i) = mean(relevantResults.correct);
end
humanHumanCorrelation = corr(...
    humanCorrectHalfs(:,1), humanCorrectHalfs(:,2));
% model
[modelNames, modelTimestepNames, timesteps] = ...
    collectModelProperties(modelResults);
modelHumanCorrelations = NaN(size(modelTimestepNames));
modelCorrect = NaN([length(presIds), size(modelTimestepNames)]);
for i = 1:numel(modelTimestepNames)
    for cri = 1:size(modelCorrect, 1);
        pres = presIds(cri);
        relevantResults = modelResults(...
            strcmp(modelTimestepNames(i), modelResults.name) & ...
            modelResults.pres == pres, :);
        assert(~isempty(relevantResults));
        modelCorrect(cri, i) = mean(relevantResults.correct);
    end
    modelHumanCorrelations(i) = corr(modelCorrect(:, i), humanCorrect(:));
end
% plot
bar(modelHumanCorrelations', ...
    'EdgeColor', 'none');
box off;
hold on;
plot(get(gca, 'xlim'), [humanHumanCorrelation humanHumanCorrelation], ...
    '-', 'Color', [1 0 0]);
ylim([-0.65 1]);
% labels
xlabels = arrayfun(@(i) ...
    strjoin(cellstr(num2str(timesteps(:, i))), '\n'), ...
    1:size(timesteps, 2), ...
    'UniformOutput', false);
my_xticklabels(1:length(xlabels), xlabels);
set(gca,'TickDir', 'in');
set(gca,'TickLength', [0.02 0.02]);
set(gca,'XTick', 1:length(modelTimestepNames));
for i = 1:size(modelNames, 1)
    text(mean(get(gca, 'xlim')), mean(modelHumanCorrelations(i, :)), ...
        modelNames{i});
end
xlabel('Time step');
ylabel('Corr. with Human');
hold off;

figure('Name', 'Similarity Exemplars');
for modelType = 1:size(modelTimestepNames, 1)
    for model = 1:size(modelTimestepNames, 2)
        subplot(size(modelTimestepNames, 1), size(modelTimestepNames, 2), ...
            (modelType - 1) * size(modelTimestepNames, 2) + model);
        plot(100 * humanCorrect, 100 * modelCorrect(:, modelType, model),...
            '.', 'Color', [0.7 0.7 0.7], 'MarkerSize', 10);
        h = lsline; set(h, 'Color', 'k');
        correlation = corr(modelCorrect(:, modelType, model), ...
            humanCorrect(:, 1));
        title(sprintf('r = %.2f', correlation));
        xlabel('Performance (human)'); axis square;
        if(model == 1)
            ylabel(['Performance (' modelNames{modelType} ')']);
        end
    end
end
end

function [abbreviatedNames, timestepNames, timesteps] = ...
    collectModelProperties(modelResults)
modelPrefixes = {'rnn', 'caffe'};
typeAbbreviations = {'RNN', 'hop'};
uniqueNames = sort(unique(modelResults.name));
modelPresent = cell2mat(...
    cellfun(@(s) any(cell2mat(strfind(lower(uniqueNames), s))), ...
    modelPrefixes, 'UniformOutput', false));
abbreviatedNames = typeAbbreviations(logical(modelPresent));
numModelTypes = sum(modelPresent);
timestepNames = cell(length(uniqueNames) / numModelTypes, numModelTypes);
timesteps = NaN(length(uniqueNames) / numModelTypes, numModelTypes);
i = 1;
for typePrefix = modelPrefixes
    typeTimestepNames = uniqueNames(~cellfun(@isempty, ...
        strfind(lower(uniqueNames), typePrefix)));
    typeTimesteps = cell2mat(cellfun(@(name) timestepFromName(name), ...
        typeTimestepNames, 'UniformOutput', false));
    [typeTimesteps, sortIndices] = sort(typeTimesteps, 'ascend');
    typeTimestepNames = typeTimestepNames(sortIndices);
    timestepNames(i:i+length(typeTimestepNames)-1) = typeTimestepNames;
    timesteps(i:i+length(typeTimesteps)-1) = typeTimesteps;
    i = i + length(typeTimestepNames);
end
timestepNames = timestepNames'; timesteps = timesteps';
end

function timestep = timestepFromName(classifierName)
token = regexp(classifierName, '_t([0-9]+)', 'tokens');
if isempty(token)
    timestep = 0;
else
    timestep = str2double(token{1}{1});
end
end
