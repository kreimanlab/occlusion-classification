function [images, labels] = ...
    getExperimentalData(dataFile, labelFile)
if nargin < 2
    dataFile = 'KLAB325.mat';
    labelFile = 'data_occlusion_klab325v2_origimages';
end

load(dataFile);
images = [img_mat(1,1:5), img_mat(1,61:65)];
load(labelFile);
labels = [data.truth(1:5,1); data.truth(61:65,1)];