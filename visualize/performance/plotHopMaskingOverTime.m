function plotHopMaskingOverTime(hopMaskingResults, hopResults256)
%% load results
if ~exist('hopResults256', 'var')
    timeResultsHop = load('data/results/classification/hoptimes-trainAll.mat');
    timeResultsHop = timeResultsHop.results;
    hopResults256 = filterResults(timeResultsHop, ...
        @(r) strcmp(r.name, 'caffenet_fc7-bipolar0-hop_t256-libsvmccv'));
end
%% load experiment data
experimentData = load('data_occlusion_klab325v2.mat');
experimentData = experimentData.data;

timesteps = [2, 4, 8, 16, 32, 64, 256];
accuracies = NaN(numel(timesteps), numel(hopMaskingResults));
for timeIter = 1:numel(timesteps)
    %% collect
    t = timesteps(timeIter);
    if t == 256 % no mask
        maskingResults = hopResults256;
    else
        if t == 0
            pattern = '^sumFeatures_alexnet-relu7-bipolar0_alexnet-relu7-masked-bipolar0-hop_t256-libsvmccv$';
        else
            pattern = ['^.*.bipolar0-hop_t', num2str(t), '_.*-hop_t256-libsvmccv$'];
        end
        maskingResults = filterResults(hopMaskingResults, ...
            @(r) cellfun(@(i) ~isempty(i), regexp(r.name, pattern)));
        maskingResults = joinExperimentData(maskingResults, experimentData);
    end
    assert(sum(cellfun(@(r) size(r, 1), maskingResults)) == 13000);
    
    accuracies(timeIter, :) = collectAccuracies(maskingResults);
end
%% plot
performances = mean(accuracies, 2);
errors = stderrmean(accuracies, 2);
errorbar(timesteps, performances, errors);
hold on;
plot(xlim(), [20, 20], 'k--'); % chance
xlabel('mask SOA');
ylabel('% correct');
ylim([0, 100]);
hold off;
end
