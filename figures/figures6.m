function corrData = figures6(corrData)

%% collect data
results = load('data/results/classification/fc7_bipolar_hop_RNN.mat');
results = results.results;
rnnResults = convertRnnResults();
% vs visibility
visibilityResults = filterResults(results, @(r) ismember(r.name, ...
    {'caffenet_fc7-libsvmccv', ...
    'caffenet_fc7-bipolar0-hop_t300-libsvmccv', ...
    'RNN_features_fc7_noRelu_t4-libsvmccv'}));
% vs time
t0Results = filterResults(rnnResults, @(r) strcmp(r.name, 'RNN_fc7_noRelu_t0'));
timeResultsHop = load('data/results/classification/hoptimes-trainAll.mat');
timeResultsHop = timeResultsHop.results;
timeResultsHop = {vertcat(timeResultsHop{:})};
timestepsHop = [5, 15, 30, 100];
timestepsRnn = 1:4;
t0ResultsHop = t0Results;
t0ResultsHop{1}.name = repmat({'caffenet_fc7_t0'}, [size(t0ResultsHop{1}, 1), 1]);
timeResultsHop = mergeRnnResults( ...
    filterResults(timeResultsHop, @(r) cellfun(@(m) ~isempty(m), ...
    regexp(r.name, ['caffenet_fc7-bipolar0-hop_t(' ...
    timesteps2regexp(timestepsHop) ')-libsvmccv']))), ...
    t0ResultsHop);
t0ResultsRnn = t0Results;
t0ResultsRnn{1}.name = repmat({'RNN_fc7_noRelu_t0'}, [size(t0ResultsRnn{1}, 1), 1]);
timeResultsRnn = mergeRnnResults(t0ResultsRnn, ...
    filterResults(rnnResults, @(r) cellfun(@(m) ~isempty(m), ...
    regexp(r.name, ['RNN.*_t(' timesteps2regexp(timestepsRnn) ')']))));
timeResults = mergeRnnResults(timeResultsHop, timeResultsRnn);

%% tsne vs time
figure('Name', '6B-tsne_vs_time');
dataset = load('data/data_occlusion_klab325v2.mat');
dataset = dataset.data;
dataSelection = 1:size(dataset, 1);
featureProviderFactory = FeatureProviderFactory(dataset, dataSelection);
featureExtractors = {...
    featureProviderFactory.get(AlexnetFc7Features()), ...
    featureProviderFactory.get(HopFeatures(15, BipolarFeatures(0, AlexnetFc7Features()))), ...
    featureProviderFactory.get(HopFeatures(100, BipolarFeatures(0, AlexnetFc7Features()))); ...
    featureProviderFactory.get(AlexnetFc7Features()), ...
    RnnFeatureProvider(dataset, RnnFeatures(2, [])), ...
    RnnFeatureProvider(dataset, RnnFeatures(4, [])); ...
    };
plotWholeVsOccludedTsne(featureExtractors);

%% performances vs visibility
figure('Name', '6C-performance_vs_visibility');
displayResults(visibilityResults);
hold on;
plotRnnTrain1CatResults();
box off;
hold off;

%% performances vs time
figure('Name', '6D-performance_vs_time');
plotOverallPerformanceOverTime(timeResults);

%% correlations vs time
figure('Name', '6E-correlation_vs_time');
if ~exist('corrData', 'var')
    corrData = collectModelHumanCorrelationData(timeResults);
end
plotCorrelationOverTime(corrData);
end

function str = timesteps2regexp(timesteps)
str = [sprintf('%d|', timesteps(1:end-1)), num2str(timesteps(end))];
end
