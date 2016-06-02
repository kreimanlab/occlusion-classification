function displayResultsHop(type, results, ...
    percentBlackMin, percentBlackMax)
%HOPSIZE Performance for different hopsizes
if ~exist('percentBlackMin', 'var')
    percentBlackMin = 75;
end
if ~exist('percentBlackMax', 'var')
    percentBlackMax = 80;
end

if strcmp(type, 'size')
    pattern = '\-hop([0-9]+)';
elseif strcmp(type, 'time')
    pattern = '\-hop_t([0-9]+)';
else
    error(['Unknown type ' type]);
end

%% Stats
kfolds = length(results);
classifierNames = unique(results{1}.name);
hopsizes = zeros(length(classifierNames), 1);
for i = 1:length(hopsizes)
    token = regexp(classifierNames{i}, pattern, 'tokens');
    hopsizes(i) = str2num(token{1}{1});
end
accuracies = collectAccuracies(results, ...
    percentBlackMin, percentBlackMax, classifierNames);
dimKfolds = 2;
meanValues = mean(accuracies, dimKfolds, 'omitnan');
standardErrorOfTheMean = std(accuracies, 0, dimKfolds, 'omitnan') / ...
    sqrt(kfolds);

%% Plot
xye = [hopsizes, meanValues, standardErrorOfTheMean];
xye = sortrows(xye, 1);
errorbar(xye(:, 1), xye(:, 2), xye(:, 3), 'o-');
if strcmp(type, 'size')
    xlabel('Hopfield size');
elseif strcmp(type, 'time')
    xlabel('Timestep');
end
ylabel(['Performance with ' num2str(100 - percentBlackMax) ...
    ' - ' num2str(100 - percentBlackMin) '% visibility']);
end
