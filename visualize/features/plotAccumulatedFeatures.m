function plotAccumulatedFeatures(wholeFeatures)
dataset = load('data/data_occlusion_klab325v2.mat');
dataset = dataset.data(dataset.data.pres <= 300, :);

if size(wholeFeatures, 1) == 325
    wholeFeatures = wholeFeatures(1:300, :);
end
assert(size(wholeFeatures, 1) == 300);
wholeFeatures = bipolarize(wholeFeatures, 0)';
% wholeFeatures = downsampleVar(1000, wholeFeatures')';
wholeRows = getRows(dataset, (1:size(wholeFeatures, 2))', true);
wholeLabels = dataset.truth(wholeRows);
sizeBins = size(wholeFeatures, 2) / length(unique(wholeLabels));
numBins = size(wholeFeatures, 2) / sizeBins;

figure('Name', 'features of 300 whole images');
% plain
subplot(1, 4, 1);
imagesc(wholeFeatures);
colorbar;
colormap(flipud(gray));
line(repmat((1:numBins-1)' * sizeBins, [1 2]), ...
    [0 size(wholeFeatures, 1)], 'Color', 'red');
title('Plain features');
% mean
subplot(1, 4, 2);
accumulate(wholeFeatures, wholeLabels, @(f, d) bipolarize(mean(f, d), 0.3));
title('thresholded mean');
% median
subplot(1, 4, 3);
accumulate(wholeFeatures, wholeLabels, @median);
title('median');
% logical
subplot(1, 4, 4);
orAll = curry(@logicalAll, @or, @zeros);
accumulate(wholeFeatures, wholeLabels, orAll);
title('or');
end

function accumulate(wholeFeatures, wholeLabels, fnc)
uniqueLabels = unique(wholeLabels);
accumulatedFeatures = zeros(size(wholeFeatures, 1), length(uniqueLabels));
for i = 1:length(uniqueLabels)
    accumulatedFeatures(:, i) = fnc(wholeFeatures(:, wholeLabels == uniqueLabels(i)), 2);
end
imagesc(accumulatedFeatures);
colorbar;
colormap(flipud(gray));
end

function result = logicalAll(fnc, initialFnc, features, ~)
features(features == -1) = 0;
result = initialFnc(size(features, 1), 1);
for i = 1:size(features, 2)
    result = fnc(result, features(:, i));
end
result = double(result);
result(result == 0) = -1;
end

function rows = getRows(dataset, pres, uniqueRows)
if uniqueRows
    [~, rows] = unique(dataset, 'pres');
else
    rows = 1:size(dataset, 1);
end
rows = rows(ismember(dataset.pres(rows), pres));
assert(all(sort(unique(dataset.pres(rows))) == sort(pres)));
if uniqueRows
    assert(length(rows) == length(pres));
end
end
