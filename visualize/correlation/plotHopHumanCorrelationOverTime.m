function plotHopHumanCorrelationOverTime(modelResults)
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
modelNames = {'caffenet_fc7-bipolar0-libsvmccv',...
    'caffenet_fc7-bipolar0-hop_t1-libsvmccv',...
    'caffenet_fc7-bipolar0-hop_t5-libsvmccv',...
    'caffenet_fc7-bipolar0-hop_t10-libsvmccv',...
    'caffenet_fc7-bipolar0-hop_t15-libsvmccv'};
modelTimesteps = [0, ...
    cellfun(@(name) timestepFromName(name), modelNames(2:end), ...
    'UniformOutput', false)];
modelHumanCorrelations = NaN(length(modelNames), 1);
for i = 1:length(modelNames)
    modelCorrect = NaN(length(presIds), 1);
    for cri = 1:size(modelCorrect, 1);
        pres = presIds(cri);
        modelCorrect(cri) = mean(modelResults.correct(...
            strcmp(modelNames(i), modelResults.name) & ...
            modelResults.pres == pres));
    end
    modelHumanCorrelations(i) = corr(modelCorrect(:), humanCorrect(:));
end
% plot
bar(modelHumanCorrelations, ...
    'EdgeColor', 'none', 'FaceColor', [0.7 0.7 0.7]);
box off;
hold on;
plot(get(gca, 'xlim'), [humanHumanCorrelation humanHumanCorrelation], ...
    '-', 'Color', [1 0 0]);
ylim([-0.65 1]);
% labels
set(gca,'TickDir', 'out');
set(gca,'TickLength', [0.02 0.02]);
set(gca,'XTick', 1:length(modelNames));
set(gca,'XTickLabel', modelTimesteps);
xlabel('Time step');
ylabel('Corr. with Human');
hold off;
end

function timestep = timestepFromName(classifierName)
token = regexp(classifierName, '\-hop_t([0-9]+)', 'tokens');
timestep = str2double(token{1}{1});
end
