function computeFeaturesWhole()

dir = fileparts(mfilename('fullpath'));
addpath([dir '/../data']);

dataSelection = 1:(325/5):325;

wholeImages = getWholeImages(dataSelection);
totalLength = length(wholeImages);
features = repmat(struct('pres', [], 'c2', [], 's2', [], 'c1', [], 's1', []), ...
    totalLength, 1);
for i = 1:totalLength
    fprintf('%d/%d\n', i, totalLength);
    [c2,c1,~,~,s2,s1] = runHmax(wholeImages(i));
    features(i).pres = dataSelection(i);
    features(i).c2 = c2;
    features(i).c1 = c1;
    features(i).s2 = s2;
    features(i).s1 = s1;
end
selectionStr = num2str(dataSelection, '%d-');
save([dir '/../data/OcclusionModeling/features/klab325_orig/'...
    'hmax_all_' selectionStr(1:end-1) '.mat'], ...
    '-v7.3', 'features');
