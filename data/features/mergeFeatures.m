function [wholeFeatures, occludedFeatures] = ...
    mergeFeatures(sourceName, wholeDir, occludedDir, destName)
if ~exist('destName', 'var')
    destName = sourceName;
end

wholeFeatures = loadFeatures([wholeDir, '/', sourceName, '_1-325']);
features = wholeFeatures;
save([wholeDir, '/', destName], 'features', '-v7.3');

occludedFeatures = cell(13, 1);
for i = 1:13
    dataStart = (i - 1) * 1000 + 1;
    dataEnd = dataStart + 999;
    occludedFeatures{i} = loadFeatures(sprintf('%s/%s_%d-%d', occludedDir, sourceName, dataStart, dataEnd));
end
occludedFeatures = cell2mat(occludedFeatures);
features = occludedFeatures;
save([occludedDir, '/', destName], 'features', '-v7.3');
end

function features = loadFeatures(filepathWithoutExtension)
if exist([filepathWithoutExtension, '.txt'], 'file')
    features = dlmread([filepathWithoutExtension, '.txt'], ' ', 0, 1);
elseif exist([filepathWithoutExtension, '.mat'], 'file')
    features = load([filepathWithoutExtension, '.mat']);
    features = features.features;
else
    error('file %s.* not found', filepathWithoutExtension);
end
end
