function plotOverallPerformanceOverTime(results)
if iscell(results)
results = results{:};
end

classifierNames = unique(results.name);
timesteps = NaN(length(classifierNames), 1); % x
performances = NaN(length(classifierNames), 1); % y
for i = 1:length(timesteps)
    token = regexp(classifierNames{i}, '\-hop_t([0-9]+)', 'tokens');
    timesteps(i) = str2num(token{1}{1});
    
    currentResults = results(strcmp(results.name, classifierNames{i}), :);
    performances(i) = mean(currentResults.correct);
end
[~, sortedIndices] = sort(timesteps);
timesteps = timesteps(sortedIndices); 
performances = performances(sortedIndices) * 100;
plot(timesteps, performances, 'bo-');
text(timesteps(end-1), performances(end) + 5, 'hopfield', 'Color', 'blue');
xlabel('Time step');
ylabel('Performance');
ylim([0 100]);
hold on;
plotOverallHumanPerformance();
hold off;
end

function plotOverallHumanPerformance()
humanResults = load('data/data_occlusion_klab325v2.mat');
humanResults = filterHumanData(humanResults.data);
performance = mean(humanResults.correct) * 100;
xlim = get(gca,'xlim');
line(xlim, [performance performance], 'Color', 'black');
text(xlim(1) + (xlim(2) - xlim(1)) / 10, performance + 5, 'human');
end
