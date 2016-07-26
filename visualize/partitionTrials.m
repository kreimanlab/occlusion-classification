function [rowPartitions1, rowPartitions2] = partitionTrials(data, numPartitions)
rng(0, 'twister');
rowPartitions1 = cell(numPartitions, 1);
rowPartitions2 = cell(numPartitions, 1);

subjects = unique(data.subject);
for p = 1:numPartitions
    subjectHalf1 = subjects(randperm(length(subjects), ...
        round(length(subjects) / 2)));
    subjectHalf2 = setdiff(subjects, subjectHalf1);
    rowPartitions1{p} = find(ismember(data.subject, subjectHalf1));
    rowPartitions2{p} = find(ismember(data.subject, subjectHalf2));
end
end
