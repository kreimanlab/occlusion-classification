function data = createLessOccludedImages(pres)

imagesData = load('KLAB325.mat');
if ~exist('pres', 'var')
    pres = (1:numel(imagesData.img_mat))';
end
data = load('data_occlusion_klab325v2.mat');
data = data.data;
gray = 128;
% options
repetitions = 15;
numBubbles = 5;
bubbleSize = [22, 30, 40];

rng(0, 'twister');
%% images
rawImages = repmat(imagesData.img_mat(pres)', repetitions, 1);
backgroundMasks = repmat(imagesData.bkgMask(pres)', repetitions, 1);
pres = repmat(pres, repetitions, 1);
% occlusion
disp('creating bubbles...');
[numBubbles, bubbleCenters, bubbleSigmas, occluded] = ...
    createBubbles(numel(rawImages), size(rawImages{1}), ...
    numBubbles, bubbleSize);
disp('occluding images...');
[images, imagesVisible] = prepareOccludeImages(...
    rawImages, backgroundMasks, ...
    gray, numBubbles, bubbleCenters, bubbleSigmas);

%% save
fprintf('saving...\n');
black = 100 - imagesVisible;
truth = arrayfun(@(p) data.truth(find(data.pres == p, 1)), pres);
bubble_centers = bubbleCenters; nbubbles = numBubbles;
data = table(pres, occluded, bubble_centers, bubbleSigmas, nbubbles, ...
    truth, black);
data = table2dataset(data); % experiment computer does not support tables

saveDir = fileparts(mfilename('fullpath'));
save(sprintf('%s/data_occlusion_klab325-high_visibility.mat', saveDir), ...
    'images', 'data');
saveImages(sprintf('%s/occluded_images', saveDir), images);
end
