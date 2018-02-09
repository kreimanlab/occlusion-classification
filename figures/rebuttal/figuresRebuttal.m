function figuresRebuttal()
%% collect data
% Caffenet pool5
caffenetPool5Results = load('data/results/classification/caffenet-pool5.mat');
caffenetPool5Results = filterResults(caffenetPool5Results.results, ...
    @(r) cellfun(@(m) ~isempty(m), ...
    regexp(r.name, '^caffenet-pool5-downsample2-(bipolar0-)?(hop_t8-)?libsvmccv$')));
% Caffenet fc7
caffenetFc7ResultsNoHop = load('data/results/classification/fc7_bipolar_hop_RNN.mat');
caffenetFc7ResultsHop = load('data/results/classification/hoptimes-trainAll.mat');
caffenetFc7Results = mergeResults(caffenetFc7ResultsNoHop.results, ...
    caffenetFc7ResultsHop.results);
caffenetFc7Results = filterResults(caffenetFc7Results, ...
    @(r) cellfun(@(m) ~isempty(m), ...
    regexp(r.name, '^caffenet_fc7-(bipolar0-)?(hop_t16-)?libsvmccv$')));
caffenetFc7Results = changeResults(caffenetFc7Results, 'black', []);
caffenetFc7Results = changeResults(caffenetFc7Results, 'pres', []);
% VGG16 pool5
% vgg16Pool5Results = load('data/results/classification/vgg16pool5.mat');
% vgg16Pool5Results = vgg16Pool5Results.results;
% VGG16 fc1
vgg16Fc1Results = load('data/results/classification/vgg16fc1.mat');
vgg16Fc1Results = filterResults(vgg16Fc1Results.results, ...
    @(r) cellfun(@(m) ~isempty(m), ...
    regexp(r.name, '^vgg16-fc1-(bipolar0-)?(hop_t64-)?libsvmccv$')));
% VGG16 fc2
vgg16Fc2Results = load('data/results/classification/vgg16fc2.mat');
vgg16Fc2Results = filterResults(vgg16Fc2Results.results, ...
    @(r) cellfun(@(m) ~isempty(m), ...
    regexp(r.name, '^vgg16-fc2-(bipolar0-)?(hop_t250-)?libsvmccv$')));
% VGG19 pool5
vgg19Pool5Results = load('data/results/classification/vgg19-block5_pool-downsample6.mat');
vgg19Pool5Results = filterResults(vgg19Pool5Results.results, ...
    @(r) cellfun(@(m) ~isempty(m), ...
    regexp(r.name, '^vgg19-block5_pool-downsample6-(bipolar0-)?(hop_t2-)?libsvmccv$')));
% VGG19 fc1
vgg19Fc1Results = load('data/results/classification/vgg19fc1.mat');
vgg19Fc1Results = filterResults(vgg19Fc1Results.results, ...
    @(r) cellfun(@(m) ~isempty(m), ...
    regexp(r.name, '^vgg19-fc1-(bipolar0-)?(hop_t64-)?libsvmccv$')));
% VGG19 fc2
vgg19Fc2Results = load('data/results/classification/vgg19fc2.mat');
vgg19Fc2Results = filterResults(vgg19Fc2Results.results, ...
    @(r) cellfun(@(m) ~isempty(m), ...
    regexp(r.name, '^vgg19-fc2-(bipolar0-)?(hop_t130-)?libsvmccv$')));
% ResNet
resnetNoTopResults = load('data/results/classification/resnet50-noIncludeTop.mat');
resnetBipolarResults = load('data/results/classification/resnet50-bipolar0.mat');
resnetBipolar2Results = load('data/results/classification/resnet50-bipolar0.2257.mat');
resnetNoTopResults = mergeResults(resnetNoTopResults.results, ...
    resnetBipolarResults.results, resnetBipolar2Results.results);
% ResNet50 40
resnet50Activation40Results = load('data/results/classification/resnet50-activation_40-downsample49.mat');
resnet50Activation40Results = filterResults(resnet50Activation40Results.results, ...
    @(r) cellfun(@(m) ~isempty(m), ...
    regexp(r.name, '^resnet50-activation_40-downsample49-(bipolar0-)?(hop_t8-)?libsvmccv$')));
% ResNet50 41
resnet50Activation41Results = load('data/results/classification/resnet50-activation_41-downsample6.mat');
resnet50Activation41Results = filterResults(resnet50Activation41Results.results, ...
    @(r) cellfun(@(m) ~isempty(m), ...
    regexp(r.name, '^resnet50-activation_41-downsample6-(bipolar0-)?(hop_t32-)?libsvmccv$')));
% ResNet50 42
resnet50Activation42Results = load('data/results/classification/resnet50-activation_42-downsample6.mat');
resnet50Activation42Results = filterResults(resnet50Activation42Results.results, ...
    @(r) cellfun(@(m) ~isempty(m), ...
    regexp(r.name, '^resnet50-activation_42-downsample6-(bipolar0-)?(hop_t32-)?libsvmccv$')));
% ResNet50 43
resnet50Activation43Results = load('data/results/classification/resnet50-activation_43-downsample24.mat');
resnet50Activation43Results = filterResults(resnet50Activation43Results.results, ...
    @(r) cellfun(@(m) ~isempty(m), ...
    regexp(r.name, '^resnet50-activation_43-downsample24-(bipolar0-)?(hop_t16-)?libsvmccv$')));
% ResNet50 44
resnet50Activation44Results = load('data/results/classification/resnet50-activation_44-downsample6.mat');
resnet50Activation44Results = filterResults(resnet50Activation44Results.results, ...
    @(r) cellfun(@(m) ~isempty(m), ...
    regexp(r.name, '^resnet50-activation_44-downsample6-(bipolar0-)?(hop_t16-)?libsvmccv$')));
% ResNet50 45
resnet50Activation45Results = load('data/results/classification/resnet50-activation_45-downsample6.mat');
resnet50Activation45Results = filterResults(resnet50Activation45Results.results, ...
    @(r) cellfun(@(m) ~isempty(m), ...
    regexp(r.name, '^resnet50-activation_45-downsample6-(bipolar0-)?(hop_t32-)?libsvmccv$')));
% ResNet50 46
resnet50Activation46Results = load('data/results/classification/resnet50-activation_46-downsample24.mat');
resnet50Activation46Results = filterResults(resnet50Activation46Results.results, ...
    @(r) cellfun(@(m) ~isempty(m), ...
    regexp(r.name, '^resnet50-activation_46-downsample24-(bipolar0-)?(hop_t8-)?libsvmccv$')));
% ResNet50 47
resnet50Activation47Results = load('data/results/classification/resnet50-activation_47-downsample6.mat');
resnet50Activation47Results = filterResults(resnet50Activation47Results.results, ...
    @(r) cellfun(@(m) ~isempty(m), ...
    regexp(r.name, '^resnet50-activation_47-downsample6-(bipolar0-)?(hop_t90-)?libsvmccv$')));
% ResNet50 48
resnet50Activation48Results = load('data/results/classification/resnet50-activation_48-downsample6.mat');
resnet50Activation48Results = filterResults(resnet50Activation48Results.results, ...
    @(r) cellfun(@(m) ~isempty(m), ...
    regexp(r.name, '^resnet50-activation_48-downsample6-(bipolar0-)?(hop_t16-)?libsvmccv$')));
% ResNet50 49
resnet50Activation49Results = load('data/results/classification/resnet50-activation_49-downsample24.mat');
resnet50Activation49Results = filterResults(resnet50Activation49Results.results, ...
    @(r) cellfun(@(m) ~isempty(m), ...
    regexp(r.name, '^resnet50-activation_49-downsample24-(bipolar0-)?(hop_t4-)?libsvmccv$')));
% ResNet50 flatten1
resnet50Flatten1Results = load('data/results/classification/resnet50-flatten_1.mat');
resnet50Flatten1Results = resnet50Flatten1Results.results;
% InceptionV3 mixed10
inceptionMixed10Results = load('data/results/classification/inceptionv3-mixed10-downsample6.mat');
inceptionMixed10Results = filterResults(inceptionMixed10Results.results, ...
    @(r) cellfun(@(m) ~isempty(m), ...
    regexp(r.name, '^inceptionv3((-227)|(-mixed10))-downsample6(-bipolar0)?(-hop_t16)?-libsvmccv$')));
% all results
allResults = mergeResults(...%     vgg16Pool5Results, ...
    vgg16Fc1Results, vgg16Fc2Results, ...
    vgg19Pool5Results, vgg19Fc1Results, vgg19Fc2Results, ...
    resnet50Activation40Results, resnet50Activation41Results, ...
    resnet50Activation42Results, resnet50Activation43Results, ...
    resnet50Activation44Results, resnet50Activation45Results, ...
    resnet50Activation46Results, resnet50Activation47Results, ...
    resnet50Activation48Results, resnet50Activation49Results, ...
    resnet50Flatten1Results, ...
    inceptionMixed10Results);
noHopResults = filterResults(allResults, ...
    @(r) ~contains(r.name, 'hop'));
onlyHopResults = filterResults(allResults, ...
    @(r) contains(r.name, 'hop'));
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
figures(end + 1) = figure('Name', 'R-performance_vs_visibility-caffenet-pool5');
displayResults(caffenetPool5Results);
figures(end + 1) = figure('Name', 'R-performance_vs_visibility-caffenet-fc7');
displayResults(caffenetFc7Results);
% figures(end + 1) = figure('Name', 'R-performance_vs_visibility-vgg16pool5');
% displayResults(vgg16Pool5Results);
figures(end + 1) = figure('Name', 'R-performance_vs_visibility-vgg16fc1');
displayResults(vgg16Fc1Results);
figures(end + 1) = figure('Name', 'R-performance_vs_visibility-vgg16fc2');
displayResults(vgg16Fc2Results);
figures(end + 1) = figure('Name', 'R-performance_vs_visibility-vgg19pool5');
displayResults(vgg19Pool5Results);
figures(end + 1) = figure('Name', 'R-performance_vs_visibility-vgg19fc1');
displayResults(vgg19Fc1Results);
figures(end + 1) = figure('Name', 'R-performance_vs_visibility-vgg19fc2');
displayResults(vgg19Fc2Results);
figures(end + 1) = figure('Name', 'R-performance_vs_visibility-resnet50-noIncludeTop');
displayResults(resnetNoTopResults);
figures(end + 1) = figure('Name', 'R-performance_vs_visibility-resnet50-activation_40');
displayResults(resnet50Activation40Results);
figures(end + 1) = figure('Name', 'R-performance_vs_visibility-resnet50-activation_41');
displayResults(resnet50Activation41Results);
figures(end + 1) = figure('Name', 'R-performance_vs_visibility-resnet50-activation_42');
displayResults(resnet50Activation42Results);
figures(end + 1) = figure('Name', 'R-performance_vs_visibility-resnet50-activation_43');
displayResults(resnet50Activation43Results);
figures(end + 1) = figure('Name', 'R-performance_vs_visibility-resnet50-activation_44');
displayResults(resnet50Activation44Results);
figures(end + 1) = figure('Name', 'R-performance_vs_visibility-resnet50-activation_45');
displayResults(resnet50Activation45Results);
figures(end + 1) = figure('Name', 'R-performance_vs_visibility-resnet50-activation_46');
displayResults(resnet50Activation46Results);
figures(end + 1) = figure('Name', 'R-performance_vs_visibility-resnet50-activation_47');
displayResults(resnet50Activation47Results);
figures(end + 1) = figure('Name', 'R-performance_vs_visibility-resnet50-activation_48');
displayResults(resnet50Activation48Results);
figures(end + 1) = figure('Name', 'R-performance_vs_visibility-resnet50-activation_49');
displayResults(resnet50Activation49Results);
figures(end + 1) = figure('Name', 'R-performance_vs_visibility-resnet50-flatten1');
displayResults(resnet50Flatten1Results);
figures(end + 1) = figure('Name', 'R-performance_vs_visibility-inceptionv3');
displayResults(inceptionMixed10Results);

figures(end + 1) = figure('Name', 'R-performance_vs_visibility-all-no_hop');
displayResults(noHopResults);
figures(end + 1) = figure('Name', 'R-performance_vs_visibility-all-only_hop');
displayResults(onlyHopResults);

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
figs = plotWholeVsOccludedTsne(featureExtractors, 'R-tsne', 0, 2048);
figures(end + 1:end + numel(figs)) = figs;

%% feature distribution
figures(end + 1) = figure('Name', 'Distribution of feature values');
plotFeatureDistribution();

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
