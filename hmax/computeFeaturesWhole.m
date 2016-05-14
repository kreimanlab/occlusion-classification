function computeFeaturesWhole()

dir = fileparts(mfilename('fullpath'));
addpath([dir '/../data']);

wholeImages = getWholeImages();
features = repmat(struct('c2', [], 's2', [], 'c1', [], 's1', []), ...
    length(wholeImages), 1);
for i = 1:length(wholeImages)
    fprintf('%d/%d\n', i, length(wholeImages));
    [c2,c1,~,~,s2,s1] = runHmax(wholeImages(i));
    features(i).c2 = c2;
    features(i).c1 = c1;
    features(i).s2 = s2;
    features(i).s1 = s1;
end
save([dir '/../data/OcclusionModeling/features/klab325_orig/hmax_all_1-325.mat'], ...
    'features');
