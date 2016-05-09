function [images, labels] = ...
    getWholeImages(selection)
if nargin < 1
    selection = 1:325;
end
dataFile = 'KLAB325.mat';
labelFile = 'data_occlusion_klab325v2_origimages';
load(dataFile);
load(labelFile);

images = img_mat(1, selection);
labels = data.truth(selection, 1);
