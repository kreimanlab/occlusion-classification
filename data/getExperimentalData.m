function [images, labels] = ...
    getExperimentalData(selection, dataFile, labelFile)
if nargin < 1
    selection = [1:3, 61:63];
    dataFile = 'KLAB325.mat';
    labelFile = 'data_occlusion_klab325v2_origimages';
end

load(dataFile);
load(labelFile);

images = img_mat(1,selection);
labels = data.truth(selection,1);
