function [modelHumanCorrs, humanHumanCorrespondence] = ...
    plotCorrespondenceOverTime(modelResults)
modelResults = collapseResults(modelResults);

%% human-human
humanResults = load('data/data_occlusion_klab325v2.mat');
[humanResults, relevantRows] = filterHumanData(humanResults.data);
humanHumanCorrespondence = calculateHumanHuman(humanResults);

%% model-human
[modelNames, modelTimestepNames, timesteps] = ...
    collectModelProperties(modelResults);
modelHumanCorrs = NaN(size(timesteps));
for modelIter = 1:size(modelTimestepNames, 1)
    for timeIter = 1:size(modelTimestepNames, 2)
        modelName = modelTimestepNames{modelIter, timeIter};
        if isempty(modelName)
            continue;
        end
        currentResults = modelResults(strcmp(modelResults.name, modelName), :);
        currentResults = arrayfun(@(row) currentResults(...
            currentResults.testrows == row, :), find(relevantRows), ...
            'UniformOutput', false);
        currentResults = vertcat(currentResults{:});
        assert(isequal(size(currentResults, 1), size(humanResults, 1)));
        assert(all(currentResults.pres == humanResults.pres));
        modelHumanCorrs(modelIter, timeIter) = getCorrespondence(...
            humanResults.correct, currentResults.correct);
    end
end

%% plot
plots = plotWithScaledX(timesteps, modelHumanCorrs);
hold on;
line(xlim(), [humanHumanCorrespondence humanHumanCorrespondence], ...
    'Color', [.7 .7 .7]);
for i = 1:size(modelNames, 1)
    text(mean(get(gca, 'xlim')), mean(modelHumanCorrs(i, :), 'omitnan'), ...
        modelNames{i}, 'Color', get(plots{i}, 'Color'));
end
xlabel('Time');
ylabel('Correspondence');
ylim([0, 1]);
set(gcf, 'Color', 'w');
box off;
hold off;
end

function corr = getCorrespondence(targets, outputs)
targets = double(targets); outputs = double(outputs);
if all(targets == outputs)
    % catch the case where we only have one distinct class (e.g. only 1s)
    corr = 1;
    return;
end
C = confusionmat(targets, outputs);
corr = sum(diag(C)) / sum(C(:));
end

function humanHumanCorrespondence = calculateHumanHuman(data)
subjects = unique(data.subject);
presIds = unique(data.pres)';
idx1 = subjects(randperm(length(subjects), round(length(subjects) / 2)));
idx2 = setdiff(subjects, idx1);
humanCorrectHalfs = NaN(length(presIds), 2);
humanCorrect = NaN(length(presIds), 1);
for pres = presIds
    relevantResults = data(data.pres == pres, :);
    humanCorrectHalfs(pres, 1) = mean(relevantResults.correct(...
        ismember(relevantResults.subject, idx1)));
    humanCorrectHalfs(pres, 2) = mean(relevantResults.correct(...
        ismember(relevantResults.subject, idx2)));
    humanCorrect(pres) = mean(relevantResults.correct);
end


combinations = nchoosek(subjects, 2);
% TODO: how to find row2 of subject2 relating to row1 of subject1?
% * pres equal
% * closest visibility
% * closest euclidean distance of bubble centers
humanHumanCorrs = NaN(size(combinations, 1), 1);
for i = 1:size(combinations, 1)
    % get rows
    rows1 = find(data.subject == combinations(i, 1));
    rows2 = find(data.subject == combinations(i, 2));
    % assert no duplicates
    assert(numel(unique(data.pres(rows1))) == numel(data.pres(rows1)));
    assert(numel(unique(data.pres(rows2))) == numel(data.pres(rows2)));
    % remove objects that were not presented to the other subject
    rows1(~ismember(data.pres(rows1), data.pres(rows2))) = [];
    rows2(~ismember(data.pres(rows2), data.pres(rows1))) = [];
    % align
    [~, sortedIndeces1] = sort(data.pres(rows1));
    rows1 = rows1(sortedIndeces1);
    [~, sortedIndeces2] = sort(data.pres(rows2));
    rows2 = rows2(sortedIndeces2);
    assert(~isempty(rows1) && ~isempty(rows2));
    assert(all(data.pres(rows1) == data.pres(rows2)));
    humanHumanCorrs(i) = getCorrespondence(...
        data.correct(rows1), data.correct(rows2));
end
humanHumanCorrespondence = mean(humanHumanCorrs);
end
