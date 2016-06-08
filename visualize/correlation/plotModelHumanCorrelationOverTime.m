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
modelCorrect = NaN([length(presIds), size(modelTimestepNames)]); % pres x type x model
for model = 1:numel(modelTimestepNames)
    if isempty(modelTimestepNames{model})
        continue;
    end
    for presIter = 1:length(presIds)
        pres = presIds(presIter);
        relevantResults = modelResults(...
            strcmp(modelTimestepNames{model}, modelResults.name) & ...
            modelResults.pres == pres, :);
        assert(~isempty(relevantResults));
        modelCorrect(presIter, model) = mean(relevantResults.correct);
    end
    modelHumanCorrelations(model) = corr(...
        modelCorrect(:, model), humanCorrect(:));
end

%% plot overall correlations
bar(modelHumanCorrelations', 'EdgeColor', 'none');
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

%% plot exemplar correlations
figure('Name', 'Similarity Exemplars');
subplotRows = size(modelTimestepNames, 1);
subplotCols = size(modelTimestepNames, 2);
for modelType = 1:size(modelTimestepNames, 1)
    for model = 1:size(modelTimestepNames, 2)
        subplot(subplotRows, subplotCols, ...
            (modelType - 1) * subplotCols + model);
        hold on;
        plot(100 * humanCorrect, ...
            100 * modelCorrect(:, modelType, model),...
            '.', 'Color', [.7 .7 .7], 'MarkerSize', 10);
        h = lsline; set(h, 'Color', 'k');
        colors = ['r', 'b', 'g', 'y', 'm'];
        for pres = presIds
            category = humanResults.truth(...
                find(humanResults.pres == pres, 1));
            plot(100 * humanCorrect(pres), ...
                100 * modelCorrect(pres, modelType, model),...
                '.', 'Color', colors(category), 'MarkerSize', 10);
        end
        correlation = corr(modelCorrect(:, modelType, model), ...
            humanCorrect(:, 1));
        title(sprintf('t = %d, r = %.2f', ...
            timesteps(modelType,model), correlation));
        xlabel('Performance (human)'); axis square;
        if(model == 1)
            ylabel(['Performance (' modelNames{modelType} ')']);
        end
        if modelType == 1 && model == size(modelTimestepNames, 2)
            labelDummies = zeros(size(colors));
            for c = 1:length(colors)
                labelDummies(c) = plot(NaN, NaN, colors(c));
            end
            leg = legend(labelDummies, stringifyLabels(1:5), ...
                'Orientation', 'horizontal');
            set(leg, 'Position', [0.37 0.8 0.3 0.05], ...
                'Units', 'normalized');
        end
        hold off;
    end
end

%% highest distance (human-model) objects
topNWorst = 5;
images = load('data/KLAB325.mat');
images = images.img_mat;
figure('Name', 'Highest distance model - human');
for modelType = 1:numel(modelNames)
    lastTimestep = find(~any(isnan(modelCorrect(:, modelType, :))), 1, 'last');
    diffs = humanCorrect - modelCorrect(:, modelType, lastTimestep);
    [~, worstPres] = sort(diffs, 'descend');
    for worstIndex = 1:topNWorst
        pres = worstPres(worstIndex);
        subplot(numel(modelNames), topNWorst, ...
            (modelType - 1) * topNWorst + worstIndex);
        imshow(images{pres});
        title(sprintf('#%d %s %.0f%% - human %.0f%%', ...
            pres, modelNames{modelType}, ...
            100 * mean(modelCorrect(pres, modelType, lastTimestep)), ...
            100 * mean(humanCorrect(pres))));
    end
end
end
