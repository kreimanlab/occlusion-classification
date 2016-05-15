function computeFeaturesOccluded()

dir = fileparts(mfilename('fullpath'));
addpath([dir '/../data']);
dataSelection = 1:(325/5):325;

wholeImages = getWholeImages(dataSelection);
occlusionData = load([dir '/../data/data_occlusion_klab325v2.mat']);
occlusionData = occlusionData.data;

for selectionIter = 1:length(dataSelection)
    pres = dataSelection(selectionIter);
    currentIndices = 1:length(occlusionData);
    currentIndices = currentIndices(occlusionData.pres == pres);
    features = struct('row', [], 'pres', [], ...
        'c2', [], 's2', [], 'c1', [], 's1', []);
    for rowIter = 1:length(currentIndices)
        row = currentIndices(rowIter);
        fprintf('%d,%d/%d,%d\n', selectionIter, rowIter, ...
            length(dataSelection), length(currentIndices));
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
