function [modelHumanCorrs, humanHumanCorrespondence] = ...
    plotCorrespondenceOverTime(modelResults, modelField, humanField)
if ~exist('modelField', 'var')
    modelField = 'correct';
end
if ~exist('humanField', 'var')
    humanField = modelField;
end
rng(0, 'twister');
modelResults = collapseResults(modelResults);

%% human-human
humanResults = load('data/data_occlusion_klab325v2.mat');
[humanResults, relevantRows] = filterHumanData(humanResults.data);
humanHumanCorrespondence = calculateHumanHuman(humanResults, humanField);

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
        currentResults = collapseResults(currentResults);
        assert(isequal(size(currentResults, 1), size(humanResults, 1)));
        assert(all(currentResults.pres == humanResults.pres));
        modelHumanCorrs(modelIter, timeIter) = getCorrespondence(...
            humanResults.(humanField), currentResults.(modelField));
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
assert(isequal(size(targets), size(outputs)));
targets = double(targets); outputs = double(outputs);
if all(targets == outputs)
    % catch the case where we only have one distinct class (e.g. only 1s)
    corr = 1;
    return;
end
C = confusionmat(targets, outputs);
corr = sum(diag(C)) / sum(C(:));
end

function humanHumanCorrespondence = calculateHumanHuman(data, humanField)
subjects = unique(data.subject);
subjectHalf1 = subjects(randperm(length(subjects), round(length(subjects) / 2)));
subjectHalf2 = setdiff(subjects, subjectHalf1);
targets = cell(1);
outputs = cell(1);
iter = 1;
for subject = subjectHalf1'
    subjectPres = data.pres(data.subject == subject);
    for pres = subjectPres'
        targetData = data(...
            data.subject == subject & data.pres == pres, :);
        assert(size(targetData, 1) == 1);
        compareData = data(ismember(data.subject, subjectHalf2) & ...
            data.pres == pres, :);
        if isempty(compareData)
            continue; % ignore if no pres-match found
        end
        compareData = findHumanCompareData(targetData, compareData);        
        targets{iter} = targetData.(humanField);
        outputs{iter} = compareData.(humanField);
        iter = iter + 1;
    end
end
targets = cell2mat(reshape(targets, [numel(targets), 1]));
outputs = cell2mat(reshape(outputs, [numel(outputs), 1]));
humanHumanCorrespondence = getCorrespondence(targets, outputs);
end

function compareData = findHumanCompareData(targetData, searchData)
searchBubbles = arrayfun(@(i) ...
    searchData.bubble_centers(i, 1:searchData.nbubbles(i)), ...
    1:size(searchData, 1), 'UniformOutput', false)';
distances = bubbleDistances(...
    targetData.bubble_centers(1:targetData.nbubbles), ...
    searchBubbles);
distances = sum(distances, 2);
[~, row] = min(distances);
compareData = searchData(row, :);
end

function distances = bubbleDistances(...
    sourceBubbleCenters, compareBubbleCenters)
distances = NaN(size(compareBubbleCenters, 1), numel(sourceBubbleCenters));
for i = 1:size(compareBubbleCenters, 1)
    for b = 1:numel(sourceBubbleCenters)
        distances(i, b) = min(arrayfun(@(compareBubble) bubbleDistance(...
            sourceBubbleCenters(b), compareBubble), ...
            compareBubbleCenters{i}));
    end
end
end

function distance = bubbleDistance(bubble1, bubble2)
    imageSize = [256, 256];
    [y1, x1] = ind2sub(imageSize, bubble1);
    [y2, x2] = ind2sub(imageSize, bubble2);
    distance = pdist2([x1, y1], [x2, y2]);
end
