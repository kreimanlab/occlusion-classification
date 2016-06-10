function [corrData, totalFeatureDiffs] = figure6()

timesteps = [1:30, 40:10:100];

results = load('data/results/classification/all-libsvmccv.mat');
results = results.results;
rnnResults = convertRnnResults();
timeResultsHop = load('data/results/classification/hoptimes-trainAll.mat');
timeResultsHop = timeResultsHop.results;
timeResultsHop = mergeResults(...
    filterResults(results, @(r) ismember(r.name, ...
    {'caffenet_fc7', 'caffenet_fc7-bipolar0'})), ... % include -1 (no bipolar)
    ...%{'caffenet_fc7'})), ...
    ...%timeResults);
    filterResults(timeResultsHop, @(r) cellfun(@(m) ~isempty(m), ...
    regexp(r.name, ['caffenet_fc7-bipolar0-hop_t(' ...
    [sprintf('%d|', timesteps(1:end-1)), num2str(timesteps(end))] ...
    ')-libsvmccv']))));
timeResults = mergeRnnResults(timeResultsHop, rnnResults);

figure('units', 'normalized', 'outerposition', [0 0 1 1]); % full-screen
subplot(1, 3, 1);
fc7RnnHop = filterResults(results, @(r) ismember(r.name, ...
    {'caffenet_fc7', 'caffenet_fc7-bipolar0-hop', 'rnn'}));
displayResults(fc7RnnHop);

subplot(1, 3, 2);
plotOverallPerformanceOverTime(timeResults);
hold on;
yyaxis right;
totalFeatureDiffs = plotHopDiffsPrecomputed([0, 0, timesteps]);
ylabel('Total absolute feature difference from previous timestep');

subplot(1, 3, 3);
corrResults = mergeRnnResults(...
    filterResults(timeResultsHop, @(r) cellfun(@(m) ~isempty(m), ...
    regexp(r.name, '^caffenet_fc7-bipolar0-hop_t(1|20|100)-'))), ...
    filterResults(rnnResults, @(r) ismember(r.name, ...
    {'RNN_t0', 'RNN_t2', 'RNN_t4'})));
corrData = collectModelHumanCorrelationData(corrResults);
plotModelHumanCorrelationOverTime(corrData);
end

