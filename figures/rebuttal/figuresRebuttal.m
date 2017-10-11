function figuresRebuttal()
%% collect data
% inceptionResults = load('data/results/classification/inceptionv3.mat');
% inceptionResults = inceptionResults.results;
% % ResNet
% resnetResults = load('data/results/classification/resnet50.mat');
% resnetResults = resnetResults.results;
% vgg16BipolarResults = load('data/results/classification/resnet50-bipolar0.mat');
% vgg16BipolarResults = vgg16BipolarResults.results;
% resnetBipolar2Results = load('data/results/classification/resnet50-bipolar0.2257-hop_t16.mat');
% resnetBipolar2Results = resnetBipolar2Results.results;
% resnetResults = mergeResults(resnetResults, vgg16BipolarResults, resnetBipolar2Results);
% for t = [2, 4, 8, 16, 64, 130, 250]
%     resnetHopResults = load(sprintf('data/results/classification/resnet50-hop_t%d.mat', t));
%     resnetHopResults = resnetHopResults.results;
%     resnetResults = mergeResults(resnetResults, resnetHopResults);
% end
% VGG16
vgg16Results = load('data/results/classification/vgg16.mat');
vgg16Results = vgg16Results.results;
vgg16DownsampleBipolarResults = load('data/results/classification/vgg16-downsample6.mat');
vgg16DownsampleBipolarResults = vgg16DownsampleBipolarResults.results;
% vgg16BipolarResults = load('data/results/classification/vgg16-bipolar0.mat');
% vgg16BipolarResults = vgg16BipolarResults.results;
vgg16Results = mergeResults(vgg16Results, vgg16DownsampleBipolarResults);%, vgg16BipolarResults);
for t = [4, 16, 32, 130, 250]
    vgg16HopResults = load(sprintf('data/results/classification/vgg16-downsample6-bipolar0-hop_t%d.mat', t));
    vgg16HopResults = vgg16HopResults.results;
    vgg16Results = mergeResults(vgg16Results, vgg16HopResults);
end
% Retrain
retrainResults = load('data/results/classification/alexnet-retrain-relu7.mat');
rnn5Results = load('data/results/classification/rnntimes.mat');
alexnetResults = filterResults(rnn5Results.results, ...
    @(r) strcmp(r.name, 'RNN_features_fc7_noRelu_t0-libsvmccv'));
alexnetResults = changeResults(alexnetResults, 'name', ...
    @(r) repmat({'non re-trained Alexnet-fc7'}, [size(r, 1), 1]));
for r = 1:numel(alexnetResults)
    alexnetResults{r}.pres = [];
end
retrainResults = mergeResults(retrainResults.results, alexnetResults);

figures = NaN(0);
%% performances
% figures(end + 1) = figure('Name', 'R-performance_vs_visibility-vgg16');
% displayResults(vgg16Results);
% figures(end + 1) = figure('Name', 'R-performance_vs_visibility-resnet');
% displayResults(resnetResults);
figures(end + 1) = figure('Name', 'R-performance_vs_visibility-retrain');
displayResults(retrainResults);

%% tsne vs time
featureExtractors = {...
% RNNH
NamedFeatures('resnet50-bipolar0'), ...
NamedFeatures('resnet50-bipolar0-hop_t4'), ...
NamedFeatures('resnet50-bipolar0-hop_t16'), ...
NamedFeatures('resnet50-bipolar0-hop_t64'), ...
NamedFeatures('resnet50-bipolar0-hop_t130'), ...
NamedFeatures('resnet50-bipolar0-hop_t250')
};
% figs = plotWholeVsOccludedTsne(featureExtractors, 'R-tsne', 0, 2048);
% figures(end + 1:end + numel(figs)) = figs;
% 
% %% feature distribution
% figures(end + 1) = figure('Name', 'Distribution of feature values');
% plotFeatureDistribution();

%% save figures
for fig = figures
    figName = get(fig, 'Name');
    figName = strrep(figName, '/', '_');
    saveFile = ['figures/rebuttal/', figName];
    saveas(fig, saveFile);
    export_fig(saveFile, '-eps', fig);
    close(fig);
end
end
