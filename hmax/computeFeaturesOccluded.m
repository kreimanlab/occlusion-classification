function computeFeaturesOccluded()

dir = fileparts(mfilename('fullpath'));
addpath([dir '/../data']);

wholeImages = getWholeImages();
occlusionData = load([dir '/../data/data_occlusion_klab325v2.mat']);
occlusionData = occlusionData.data;

features = repmat(struct('c2', [], 's2', [], 'c1', [], 's1', []), ...
    size(occlusionData, 1), 1);
featuresIter = 1;
for dataIter = 1:size(occlusionData, 1)
    fprintf('%d/%d\n', dataIter, size(occlusionData, 1));
    imageNum = occlusionData.pres(dataIter);
    occludedImage = occlude(wholeImages(imageNum), dataIter, occlusionData);
    [c2,c1,~,~,s2,s1] = runHmax(occludedImage);
    features(featuresIter).c2 = c2;
    features(featuresIter).c1 = c1;
    features(featuresIter).s2 = s2;
    features(featuresIter).s1 = s1;
    
    if mod(dataIter, 1000) == 0
        save([dir '/../data/OcclusionModeling/features/data_occlusion_klab325v2/'...
            'hmax_all_' num2str(dataIter-999) '-' num2str(dataIter) '.mat'], ...
            'features');
        featuresIter = 1;
    else
        featuresIter = featuresIter + 1;
    end
end
