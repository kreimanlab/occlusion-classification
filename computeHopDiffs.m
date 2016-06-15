function [totalAbsDiffs, absDiffsPerFeature, absDiffsPerObject, absDiffsPerImage] = ...
    computeHopDiffs(timesteps, nBack, diffFnc)
if ~exist('timesteps', 'var')
    timesteps = [0, 1, 5, 20, 100];
end
if ~exist('nBack', 'var')
    nBack = 1;
end
if ~exist('diffFnc', 'var')
    diffFnc = @minus;
end

data = load('data/data_occlusion_klab325v2.mat');
data = data.data;
dataSelection = 1:13000;
presIds = unique(data.pres)';

absDiffsPerImage = NaN([numel(timesteps), numel(dataSelection)]);
absDiffsPerObject = NaN([numel(timesteps), numel(presIds)]);
absDiffsPerFeature = NaN([numel(timesteps), 4096]);
totalAbsDiffs = NaN([1, numel(timesteps)]);
prevNFeatures = NaN(nBack, length(dataSelection), 4096);
for timeIter = 1:numel(timesteps)
    t = timesteps(timeIter);
    fprintf('t = %d (%d/%d)\n', t, timeIter, numel(timesteps));
    if t < 1
        features = BipolarFeatures(0, ...
            FeatureProvider(data, dataSelection, AlexnetFc7Features()))...
            .extractFeatures(dataSelection, RunType.Test, []);
    else
        features = FeatureProvider(data, dataSelection, ...
            HopFeatures(t, BipolarFeatures(0, AlexnetFc7Features())))...
            .extractFeatures(dataSelection, RunType.Test, []);
    end
    diff = diffFnc(features, reshape(prevNFeatures(1, :, :), size(features)));
    absDiffs = abs(diff);
    absDiffsPerFeature(timeIter, :) = sum(absDiffs, 1);
    totalAbsDiffs(timeIter) = sum(absDiffsPerFeature(timeIter, :), 2);
    absDiffsPerImage(timeIter, :) = sum(absDiffs, 2);
    for pres = presIds
        rows = data.pres == pres;
        absDiffsPerObject(timeIter, pres) = ...
            sum(absDiffsPerImage(timeIter, rows), 2);
    end
    if nBack > 1
        prevNFeatures = vertcat(prevNFeatures(2:end, :, :), ...
            reshape(features, [1 size(features)]));
    else
        prevNFeatures = reshape(features, [1 size(features)]);
    end
end
save(['data/results/features/totalAbsDiffs-' ...
    datestr(datetime(), 'yyyy-mm-dd_HH-MM-SS') '.mat'], ...
    'timesteps', 'totalAbsDiffs', 'absDiffsPerFeature', ...
    'absDiffsPerImage', 'absDiffsPerObject');
