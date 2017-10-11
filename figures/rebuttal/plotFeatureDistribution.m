function plotFeatureDistribution()
alexnetWholeFeatures = load('data/features/klab325_orig/alexnet-fc7.mat');
alexnetWholeFeatures = alexnetWholeFeatures.features;
resnetWholeFeatures = load('data/features/klab325_orig/resnet50.mat');
resnetWholeFeatures = resnetWholeFeatures.features;
alexnetOccludedFeatures = load('data/features/data_occlusion_klab325v2/alexnet-fc7.mat');
alexnetOccludedFeatures = alexnetOccludedFeatures.features;
resnetOccludedFeatures = load('data/features/data_occlusion_klab325v2/resnet50.mat');
resnetOccludedFeatures = resnetOccludedFeatures.features;

nbins = 100;
subplot(2, 2, 1); makePlot(alexnetWholeFeatures, nbins); title('Alexnet whole');
subplot(2, 2, 2); makePlot(resnetWholeFeatures, nbins); title('ResNet50 whole');
subplot(2, 2, 3); makePlot(alexnetOccludedFeatures, nbins); title('Alexnet occluded');
subplot(2, 2, 4); makePlot(resnetOccludedFeatures, nbins); title('ResNet50 occluded');
end

function makePlot(features, nbins)
hist(reshape(features, [numel(features), 1]), nbins);

ratioZero = sum(reshape(features, [numel(features), 1]) == 0) / numel(features);
fprintf('%.2f%% of features are zero', ratioZero * 100);
end
