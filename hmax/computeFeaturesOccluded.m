function computeFeaturesOccluded()

dir = fileparts(mfilename('fullpath'));
addpath([dir '/../data']);
dataSelection = 1:(325/5):325;
occlusions = 100:-10:60;

wholeImages = getWholeImages();
occlusionData = load([dir '/../data/data_occlusion_klab325v2.mat']);
occlusionData = occlusionData.data;

for selectionIter = 1:length(dataSelection)
    pres = dataSelection(selectionIter);
    indices = 1:length(occlusionData);
    indices = indices(occlusionData.pres == pres); % current image
    [~, occlusionIndices] = arrayfun(@(o) ... % closest to occlusion values
        min(abs(occlusionData.black(indices) - o)), occlusions);
    indices = indices(occlusionIndices);
    features = struct('row', [], 'pres', [], ...
        'c2', [], 's2', [], 'c1', [], 's1', []);
    for rowIter = 1:length(indices)
        row = indices(rowIter);
        fprintf('%d,%d/%d,%d (%d)\n', selectionIter, rowIter, ...
            length(dataSelection), length(indices), ...
            row);
        occludedImage = occlude(wholeImages(pres), row, occlusionData);
        [c2,c1,~,~,s2,s1] = runHmax(occludedImage);
        features(rowIter).row = row;
        features(rowIter).pres = pres;
        features(rowIter).c2 = c2;
        features(rowIter).c1 = c1;
        features(rowIter).s2 = s2;
        features(rowIter).s1 = s1;
    end
    save([dir '/../data/OcclusionModeling/features/data_occlusion_klab325v2/'...
        'hmax_all_' num2str(pres) '.mat'], ...
        '-v7.3', 'features');
end
