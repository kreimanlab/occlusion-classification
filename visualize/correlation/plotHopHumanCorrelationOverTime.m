function plotHopHumanCorrelationOverTime(modelResults)
if iscell(modelResults)
modelResults = modelResults{:};
end

humanResults = load('data/data_occlusion_klab325v2.mat');
humanResults = humanResults.data;

classifierNames = unique(modelResults.name);
timesteps = NaN(length(classifierNames), 1); % x
correlations = NaN(length(classifierNames), 1); % y
for i = 1:length(timesteps)
    token = regexp(classifierNames{i}, '\-hop_t([0-9]+)', 'tokens');
    timesteps(i) = str2num(token{1}{1});
    
    currentResults = modelResults(strcmp(modelResults.name, classifierNames{i}), :);
    relatedHumanResults = humanResults(...
        ismember(humanResults.pres, currentResults.pres) & ...
        ismember(humanResults.black, currentResults.black), :);
    assert(size(currentResults, 1) == size(relatedHumanResults, 1));
    c = corrcoef(relatedHumanResults.responses, currentResults.response);
    % 2x2 diagonal with c(i,i)=1 and c(i,j)=c(j,i) 
    % -> we want one single correlation
    correlations(i) = c(1, 2);
end
bar(timesteps, correlations);
ylim([-0.5 0.5]);
xlabel('Time step');
ylabel('Corr. with Human');
end

