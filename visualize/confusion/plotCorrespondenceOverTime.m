function [modelHumanCorrs, humanHumanCorr] = ...
    plotCorrespondenceOverTime(modelResults, modelField, humanField)
if ~exist('modelField', 'var')
    modelField = 'correct';
end
if ~exist('humanField', 'var')
    humanField = modelField;
end
rng(0, 'twister');
modelResults = collapseResults(modelResults);

%% setup
[~, ~, ~, modelColors] = getModelLabels();
numPartitions = 20;
humanResults = load('data/data_occlusion_klab325v2.mat');
[humanResults, relevantRows] = filterHumanData(humanResults.data);
[rowPartitions1, rowPartitions2] = partitionTrials(humanResults, numPartitions);

%% human-human
[humanHumanCorr, humanHumanErr] = compare(...
    humanResults.(humanField), humanResults.(humanField), ...
    rowPartitions1, rowPartitions2);

%% model-human
[modelNames, modelTimestepNames, timesteps] = ...
    collectModelProperties(modelResults);
modelHumanCorrs = NaN(size(timesteps));
modelHumanErrs = NaN(size(modelHumanCorrs));
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
        assert(all(currentResults.black == humanResults.black));
        [modelHumanCorrs(modelIter, timeIter), ...
            modelHumanErrs(modelIter, timeIter)] = compare(...
            humanResults.(humanField), currentResults.(modelField), ...
            rowPartitions1, rowPartitions2);
    end
end

%% random
if strcmp(humanField, 'response_category')
    % additional performance constraint
    randomData = drawRandomly(humanResults.(humanField), humanResults.truth);
else
    randomData = drawRandomly(humanResults.(humanField));
end
[randomHumanCorr, randomHumanErr] = compare(...
    humanResults.(humanField), randomData, ...
    rowPartitions1, rowPartitions2);

%% plot
% model-human
plotArgs = cell(numel(modelColors), 2);
for i = 1:numel(modelColors)
    plotArgs{i, 1} = {'Color', modelColors{i}};
    plotArgs{i, 2} = true;
end
plots = plotWithScaledX(timesteps, modelHumanCorrs, modelHumanErrs, ...
    @shadedErrorBar, plotArgs);
hold on;
% human-human
shadedErrorBar(xlim(), [humanHumanCorr humanHumanCorr], ...
    [humanHumanErr, humanHumanErr], ...
    {'Color', [.7 .7 .7]}, true);
text(1.75 * mean(get(gca, 'xlim')), humanHumanCorr - 0.01, 'human', ...
    'Color', [.7 .7 .7]);
% random-human
shadedErrorBar(xlim(), [randomHumanCorr randomHumanCorr], ...
    [randomHumanErr, randomHumanErr], ...
    {'Color', [.8 .8 .8]}, true);
text(1.75 * mean(get(gca, 'xlim')), randomHumanCorr - 0.01, 'random', ...
    'Color', [.8 .8 .8]);
for i = 1:size(modelNames, 1)
    text(mean(get(gca, 'xlim')), mean(modelHumanCorrs(i, :), 'omitnan'), ...
        modelNames{i}, 'Color', get(plots{i}.mainLine, 'Color'));
end
xlabel('Time step');
ylabel('Correspondence');
ylim([0, 0.8]);
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
corr = sum(diag(C)) / sum(C(:)); % confusion accuracy
end


function [correspondence, sem] = compare(...
    data1, data2, rowPartitions1, rowPartitions2)
correspondences = NaN(size(rowPartitions1));
for i = 1:size(rowPartitions1, 1)
    targetRows = rowPartitions1{i};
    outputRows = rowPartitions2{i};
    targets = NaN(size(targetRows));
    outputs = NaN(size(outputRows));
    for rowIter = 1:numel(targetRows)
        targets(rowIter) = data1(targetRows(rowIter));
        outputs(rowIter) = data2(outputRows(rowIter));
    end
    correspondences(i) = getCorrespondence(targets(:), outputs(:));
end
correspondence = mean(correspondences);
sem = std(correspondences);
end

function randAnswers = drawRandomly(answers, truthConstraint)
if ~exist('truthConstraint', 'var')
    indices = randperm(numel(answers));
    randAnswers = answers(indices);
else
    r = numel(answers);
    randAnswers = answers;
    for i = 1:r
        incorrectAnswers = find(answers ~= truthConstraint);
        i1 = randperm(numel(incorrectAnswers), 1);
        i1 = incorrectAnswers(i1);
        correctAnswersI1Truth = find(answers == truthConstraint & ...
            answers == truthConstraint(i1));
        i2 = randperm(numel(correctAnswersI1Truth), 1);
        i2 = correctAnswersI1Truth(i2);
        randAnswers = swap(randAnswers, i1, i2);
    end
end
end
