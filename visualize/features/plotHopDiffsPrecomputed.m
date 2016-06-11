function totalAbsDiffs = plotHopDiffsPrecomputed(timesteps, nBacks, ...
    makeLegend)
if ~exist('timesteps', 'var')
    timesteps = 1:5:20;
end
if ~exist('nBacks', 'var')
    nBacks = 1;
end
if ~exist('makeLegend', 'var')
    makeLegend = false;
end

data = load('data/data_occlusion_klab325v2.mat');
data = data.data;
dataSelection = 1:13000;

totalAbsDiffs = NaN([numel(nBacks), numel(timesteps)]);
for nIter = 1:numel(nBacks)
    n = nBacks(nIter);
    prevNFeatures = NaN(n, length(dataSelection), 4096);
    for i = 1:numel(timesteps)
        t = timesteps(i);
        if t < 1
            features = BipolarFeatures(0, ...
                FeatureProvider(data, dataSelection, AlexnetFc7Features()))...
                .extractFeatures(dataSelection, RunType.Test, []);
        else
            features = FeatureProvider(data, dataSelection, ...
                HopFeatures(t, BipolarFeatures(0, AlexnetFc7Features())))...
                .extractFeatures(dataSelection, RunType.Test, []);
        end
        diff = features - reshape(prevNFeatures(1, :, :), size(features));
        totalAbsDiffs(nIter, i) = sum(sum(abs(diff), 1), 2);
        if n > 1
            prevNFeatures = vertcat(prevNFeatures(2:end, :, :), ...
                reshape(features, [1 size(features)]));
        else
            prevNFeatures = reshape(features, [1 size(features)]);
        end
    end
    plot(totalAbsDiffs(nIter, :));
    hold on;
end
if makeLegend
    legend(arrayfun(@(n) [num2str(n) '-back'], nBack, ...
        'UniformOutput', false));
end
hold off;
