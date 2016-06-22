function rnnResults = plotCorrespondenceOverTime(rnnResults)
if ~exist('rnnResults', 'var')
    rnnResults = convertRnnResults;
end

humanResults = load('data/data_occlusion_klab325v2.mat');
humanResults = humanResults.data;
ids = humanResults.occluded == 1 & humanResults.masked == 0 & humanResults.soa == .15;
humanResults = humanResults(ids, :);
subjects = unique(humanResults.subject);
subjects1 = subjects(randperm(length(subjects), round(length(subjects) / 2)));
subjects2 = setdiff(subjects, subjects1);
idx1 = find(ismember(humanResults.subject, subjects1));
idx2 = find(ismember(humanResults.subject, subjects2));
minNum = min(length(idx1), length(idx2));
humanHalf1Correct = humanResults.correct(idx1(1:minNum));
humanHalf2Correct = humanResults.correct(idx2(1:minNum));
humanCorr = getCorrespondence(humanHalf1Correct, humanHalf2Correct);

timesteps = 0:4;
modelNames = arrayfun(@(t) sprintf('RNN_t%d', t), timesteps, ...
    'UniformOutput', false);
modelHumanCorrs = NaN(length(modelNames), 1);
for modelIter = 1:length(modelNames)
    modelName = modelNames{modelIter};
    modelResults = rnnResults(strcmp(rnnResults.name, modelName), :);
    modelResults = modelResults(ids, :);
    assert(isequal(size(modelResults, 1), size(humanResults, 1)));
    modelHumanCorrs(modelIter) = getCorrespondence(humanResults.correct, modelResults.correct);
end
figure('Name', 'RNN-human correspondence');
plot(timesteps, modelHumanCorrs);
hold on;
line(xlim(), [humanCorr humanCorr], 'Color', [.7 .7 .7]);
xlabel('Time');
ylabel('Correspondence');
end

function corr = getCorrespondence(targets, outputs)
C = confusionmat(targets, outputs);
corr = (C(1, 1) + C(2, 2)) / sum(reshape(C, [4 1]));
end
