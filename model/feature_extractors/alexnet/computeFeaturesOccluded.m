function computeFeaturesOccluded()

dir = fileparts(mfilename('fullpath'));
addpath([dir '/../data']);
netParams = load([dir '/ressources/alexnetParams.mat']);
imagesMean = load([dir '/ressources/ilsvrc_2012_mean.mat']);
imagesMean = imagesMean.mean_data;

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
    features = struct('pres', [], 'row', [], ...
        'c1', [], 'r1', [], 'p1', [], 'n1', [], ...
        'c2', [], 'r2', [], 'p2', [], 'n2', [], ...
        'c3', [], ...
        'c4', [], ...
        'c5', [], 'r5', [], 'p5', [], ...
        'fc6', [], 'r6', [], ...
        'fc7', [], 'r7', [], ...
        'fc8', [], ...
        'prob', []);
    for rowIter = 1:length(indices)
        row = indices(rowIter);
        fprintf('%d,%d/%d,%d (%d)\n', selectionIter, rowIter, ...
            length(dataSelection), length(indices), ...
            row);
        occludedImage = occlude(wholeImages(pres), row, occlusionData);
        preparedImage = prepareGrayscaleImage(occludedImage{1}, imagesMean);
        layerOutputs = alexNetLayerOutputs(preparedImage, netParams);
        features(rowIter).row = row;
        features(rowIter).pres = pres;
        for field = fieldnames(layerOutputs)'
            features(rowIter).(field{1}) = layerOutputs.(field{1});
        end
    end
    save([dir '/../data/OcclusionModeling/features/data_occlusion_klab325v2/'...
        'alexnet_all_' num2str(pres) '.mat'], ...
        '-v7.3', 'features');
end
