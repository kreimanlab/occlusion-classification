function computeFeaturesWhole()

writeOutEvery = 10;

dir = fileparts(mfilename('fullpath'));
addpath([dir '/../data']);

wholeImages = getWholeImages();
features = repmat(struct('c2', [], 's2', [], 'c1', [], 's1', []), ...
    writeOutEvery, 1);
totalLength = length(wholeImages);
featuresIter = 1;
for dataIter = 1:totalLength
    fprintf('%d/%d\n', dataIter, totalLength);
    [c2,c1,~,~,s2,s1] = runHmax(wholeImages(dataIter));
    features(featuresIter).c2 = c2;
    features(featuresIter).c1 = c1;
    features(featuresIter).s2 = s2;
    features(featuresIter).s1 = s1;
    
    if mod(dataIter, writeOutEvery) == 0 || dataIter == totalLength
        save([dir '/../data/OcclusionModeling/features/klab325_orig/'...
            'hmax_all_' num2str(dataIter-writeOutEvery+1) '-' num2str(dataIter) '.mat'], ...
            '-v7.3', 'features');
        featuresIter = 1;
    else
        featuresIter = featuresIter + 1;
    end
end
