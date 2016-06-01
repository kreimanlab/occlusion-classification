function alexnet_bipolar_features
dataset = load('data/data_occlusion_klab325v2.mat');
dataset = dataset.data(dataset.data.pres <= 300, :);

wholeFeatures = dlmread(['data/features/klab325_orig/'...
    'caffenet_fc7_ims_1-325.txt'], ' ', 0, 1);
wholeFeatures = wholeFeatures(1:300, :);
wholeFeatures = bipolarize(wholeFeatures, 0);
wholeFeatures = downsampleVar(1000, wholeFeatures)';
wholeRows = getRows(dataset, (1:size(wholeFeatures, 2))', true);
wholeLabels = dataset.truth(wholeRows);
sizeBins = size(wholeFeatures, 2) / length(unique(wholeLabels));
numBins = size(wholeFeatures, 2) / sizeBins;

figure('Name', 'features of 300 whole images');

subplot(1, 3, 1);
imagesc(wholeFeatures);
colorbar;
colormap(flipud(gray));
line(repmat((1:numBins-1)' * sizeBins, [1 2]), ...
    [0 size(wholeFeatures, 1)], 'Color', 'red');
title('Plain features');

subplot(1, 3, 2);
accumulate(wholeFeatures, wholeLabels, @mean);
title('mean');

subplot(1, 3, 3);
accumulate(wholeFeatures, wholeLabels, @median);
title('median');
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


function downsampledFeatures = downsampleVar(downsampledLength, features)
    variances = var(features, 1);
    [~, sortedIndices] = sort(variances, 'descend');
    selectedFeatureIndices = sortedIndices(1:downsampledLength);
    downsampledFeatures = features(:, selectedFeatureIndices);
end

function downsampledFeatures = downsampleFeaturesNth(downsampledLength, features)
sampleSteps = ceil(size(features, 2) / downsampledLength);
downsampledFeatures = zeros(size(features, 1), ...
    ceil(size(features, 2) / sampleSteps));
for i = 1:size(features, 1)
    downsampledFeatures(i, :) = downsample(features(i, :), ...
        sampleSteps);
end
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
