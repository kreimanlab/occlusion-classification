function corrData = figure6(corrData)
timesteps = [1, 5, 20, 100];

%% collect data
results = load('data/results/classification/all-libsvmccv.mat');
results = results.results;
rnnResults = convertRnnResults();
timeResultsHop = load('data/results/classification/hoptimes-trainAll.mat');
timeResultsHop = timeResultsHop.results;
timeResultsHop = mergeResults(...
    filterResults(results, @(r) ismember(r.name, ...
    {'caffenet_fc7', 'caffenet_fc7-bipolar0'})), ...
    filterResults(timeResultsHop, @(r) cellfun(@(m) ~isempty(m), ...
    regexp(r.name, ['caffenet_fc7-bipolar0-hop_t(' ...
    timesteps2regexp(timesteps) ')-libsvmccv']))));
timeResults = mergeRnnResults(timeResultsHop, rnnResults);
hopFeatureDiffs = load('data/results/features/totalAbsDiffs.mat');

figure('units', 'normalized', 'outerposition', [0 0 1 1]); % full-screen
%% performances per occlusion
subplot(1, 3, 1);
fc7RnnHop = filterResults(results, @(r) ismember(r.name, ...
    {'caffenet_fc7', 'caffenet_fc7-bipolar0-hop', 'rnn'}));
displayResults(fc7RnnHop);
plotRnnTrain1CatResults();

%% performances over time
subplot(1, 3, 2);
plotOverallPerformanceOverTime(timeResults);
% features
yyaxis right;
diffTimesteps = [0 timesteps];
assert(all(ismember(diffTimesteps, hopFeatureDiffs.timesteps)));
indices = ismember(hopFeatureDiffs.timesteps, diffTimesteps);
totalAbsDiffs = [NaN, hopFeatureDiffs.totalAbsDiffs(indices)]; % include -1
ylim([0, max(totalAbsDiffs) .^ 2]);
semilogy(totalAbsDiffs, '-o', 'MarkerSize', 2);
ylabel('Total absolute feature difference from previous timestep');

%% correlations over time
subplot(1, 3, 3);
corrTimestepsRnn = [0, 2, 4];
corrTimestepsHop = [1, 20, 100];
corrResults = mergeRnnResults(...
    filterResults(timeResultsHop, @(r) cellfun(@(m) ~isempty(m), ...
    regexp(r.name, ['^caffenet_fc7-bipolar0-hop_t(' ...
    timesteps2regexp(corrTimestepsHop) ')-']))), ...
    filterResults(rnnResults, @(r) cellfun(@(m) ~isempty(m), ...
    regexp(r.name, ['RNN_t(' timesteps2regexp(corrTimestepsRnn) ')']))));
if ~exist('corrData', 'var')
    corrData = collectModelHumanCorrelationData(corrResults);
end
plotModelHumanCorrelationOverTime(corrData);
end

function str = timesteps2regexp(timesteps)
str = [sprintf('%d|', timesteps(1:end-1)), num2str(timesteps(end))];
end
