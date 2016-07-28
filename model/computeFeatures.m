function computeFeatures(varargin)
%% Setup
argParser = inputParser();
argParser.KeepUnmatched = true;
argParser.addParameter('objectsForRows', [], @isnumeric);
argParser.addParameter('dataSelection', [], @isnumeric);
argParser.addParameter('trainDirectory', [], @(p) exist(p, 'dir'));
argParser.addParameter('testDirectory', [], @(p) exist(p, 'dir'));
argParser.addParameter('featureExtractors', {}, ...
    @(fs) iscell(fs) && all(cellfun(@(f) isa(f, 'FeatureExtractor'), fs)));

argParser.parse(varargin{:});
fprintf('Computing features in %s with args:\n', pwd);
disp(argParser.Results);
dataSelection = argParser.Results.dataSelection;
objectsForRows = argParser.Results.objectsForRows;
trainDir = argParser.Results.trainDirectory;
testDir = argParser.Results.testDirectory;
featureExtractors = argParser.Results.featureExtractors;
assert(~isempty(featureExtractors), 'featureExtractors must not be empty');

%% Run
[~, uniquePresRows] = unique(objectsForRows);
for featureExtractorIter = 1:length(featureExtractors)
    featureExtractor = featureExtractors{featureExtractorIter};
    % whole
    fprintf('%s train images\n', featureExtractor.getName());
    features = featureExtractor.extractFeatures(uniquePresRows, ...
        RunType.Train, []);
    saveFeatures(features, trainDir, featureExtractor, ...
        1, size(features, 1));
    
    % occluded
    for dataIter = 1:1000:numel(objectsForRows)
        dataEnd = dataIter + 999;
        if ~any(ismember(dataSelection, dataIter.dataEnd))
            continue;
        end
        fprintf('%s test images %d/%d\n', featureExtractor.getName(), ...
            dataIter, numel(objectsForRows));
        features = featureExtractor.extractFeatures(dataIter:dataEnd, ...
            RunType.Test, []);
        saveFeatures(features, testDir, ...
            featureExtractor, dataIter, dataEnd);
    end
end
end

function saveFeatures(features, dir, classifier, dataMin, dataMax)
saveFile = [dir '/' classifier.getName() '_' ...
    num2str(dataMin) '-' num2str(dataMax) '.mat'];
save(saveFile, '-v7.3', 'features');
end
