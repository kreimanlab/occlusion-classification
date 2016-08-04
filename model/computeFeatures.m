function computeFeatures(varargin)
%% Setup
argParser = inputParser();
argParser.KeepUnmatched = true;
argParser.addParameter('data', [], @(d) isa(d, 'dataset'));
argParser.addParameter('dataSelection', [], @isnumeric);
argParser.addParameter('trainDirectory', [], @(p) exist(p, 'dir'));
argParser.addParameter('testDirectory', [], @(p) exist(p, 'dir'));
argParser.addParameter('featureExtractors', {}, ...
    @(fs) iscell(fs) && all(cellfun(@(f) isa(f, 'FeatureExtractor'), fs)));
argParser.addParameter('masked', false, @(b) b == true || b == false);

argParser.parse(varargin{:});
fprintf('Computing features in %s with args:\n', pwd);
disp(argParser.Results);
dataSelection = argParser.Results.dataSelection;
data = argParser.Results.data;
trainDir = argParser.Results.trainDirectory;
testDir = argParser.Results.testDirectory;
featureExtractors = argParser.Results.featureExtractors;
assert(~isempty(featureExtractors), 'featureExtractors must not be empty');
maskImages = argParser.Results.masked;

%% Run
parallelPoolObject = parpool; % init parallel computing pool
[~, uniquePresRows] = unique(data.pres);
for featureExtractorIter = 1:length(featureExtractors)
    featureExtractor = featureExtractors{featureExtractorIter};
    if ~maskImages
        featureExtractor = ImageProvider(data, featureExtractor);
    else
        featureExtractor = MaskedImageProvider(data, featureExtractor);
    end
    % whole
    fprintf('%s train images\n', featureExtractor.getName());
    features = featureExtractor.extractFeatures(uniquePresRows, ...
        RunType.Train, []);
    saveFeatures(features, trainDir, featureExtractor, ...
        1, size(features, 1));
    
    % occluded
    parfor dataIter = 1:size(data, 1) / 1000
        dataStart = (dataIter - 1) * 1000 + 1;
        dataEnd = dataStart + 999;
        if ~any(ismember(dataSelection, dataStart:dataEnd))
            continue;
        end
        fprintf('%s test images %d/%d\n', featureExtractor.getName(), ...
            dataStart, size(data, 1));
        features = featureExtractor.extractFeatures(dataStart:dataEnd, ...
            RunType.Test, []);
        saveFeatures(features, testDir, ...
            featureExtractor, dataStart, dataEnd);
    end
end
delete(parallelPoolObject); % teardown pool
end

function saveFeatures(features, dir, classifier, dataMin, dataMax)
saveFile = [dir '/' classifier.getName() '_' ...
    num2str(dataMin) '-' num2str(dataMax) '.mat'];
save(saveFile, '-v7.3', 'features');
end
