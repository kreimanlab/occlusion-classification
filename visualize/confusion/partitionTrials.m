function [rowPartitions1, rowPartitions2] = partitionTrials(data, numPartitions)
rng(0, 'twister');
rowPartitions1 = cell(numPartitions, 1);
rowPartitions2 = cell(numPartitions, 1);

subjects = unique(data.subject);
for p = 1:numPartitions
    rows1 = NaN(0);
    rows2 = NaN(0);
    subjectHalf1 = subjects(randperm(length(subjects), round(length(subjects) / 2)));
    subjectHalf2 = setdiff(subjects, subjectHalf1);
    for subject = subjectHalf1'
        subjectPres = data.pres(data.subject == subject);
        for pres = subjectPres'
            targetRow = find(data.subject == subject & data.pres == pres);
            targetData = data(targetRow, :);
            assert(size(targetData, 1) == 1);
            compareSearchRows = find(ismember(data.subject, subjectHalf2) & ...
                data.pres == pres);
            compareSearchData = data(compareSearchRows, :);
            if isempty(compareSearchData)
                continue; % ignore if no pres-match found
            end
            [~, compareRow] = findHumanCompareData(targetData, compareSearchData);
            rows1(end + 1) = targetRow;
            rows2(end + 1) = compareSearchRows(compareRow);
        end
    end
    rowPartitions1{p} = rows1;
    rowPartitions2{p} = rows2;
end
end

function [compareData, row] = findHumanCompareData(targetData, searchData)
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
