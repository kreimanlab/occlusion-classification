function data = prepareImagenet(imagesDirectory, occludedWholeRatio)
%PREPAREIMAGENET prepares the data for fine-tuning (mixed training)
%   occludedWholeRatio: number of occluded images to train on divided by 
%   number of whole images to train on

scriptDirectory = fileparts(mfilename('fullpath'));
assert(exist('imagesDirectory', 'var') == 1);
targetDirectory = [scriptDirectory, '/processed_images/'];
mkdir(targetDirectory);

%% settings
if ~exist('occludedWholeRatio', 'var')
    occludedWholeRatio = 1/1;
end
targetImageSize = [227, 227];
convertGrayscale = false;
bubblesPerImage = 5;
bubbleSize = 14;
fprintf('using bubble size %d\n', bubbleSize);
logEvery = 1;
gray = 128;
rng(0, 'twister');

%% read images
fprintf('collecting images...\n');
imageFiles = dir([imagesDirectory, '/*.JPEG']);
images = cell(size(imageFiles));
for i = 1:numel(imageFiles)
    if mod(i - 1, logEvery) == 0 || i == numel(imageFiles)
        fprintf('%d/%d\n', i, numel(imageFiles));
    end
    images{i} = imread([imagesDirectory, '/', imageFiles(i).name]);
    images{i} = resizedCenterCrop(images{i}, targetImageSize);
    if convertGrayscale && isRgb(images{i})
        images{i} = rgb2gray(images{i});
    end
end
backgroundMasks = false; % TODO: eventually use bounding box here

%% set up ratio
numWhole = numel(images);
numOccluded = occludedWholeRatio * numWhole;
imageNums = 1:numel(images);
if numOccluded < numWhole
    wholeImageNumsToOcclude = datasample(imageNums, numOccluded, 'Replace', false);
else
    assert(mod(occludedWholeRatio, 1) == 0); % is integer - if e.g 1.5 could sample with replacement
    wholeImageNumsToOcclude = repmat(imageNums, occludedWholeRatio, 1);
end
wholeImagesToOcclude = images(wholeImageNumsToOcclude);

%% occlude images
disp('creating bubbles...');
[numBubbles, bubbleCenters, bubbleSigmas, occluded] = ...
    createBubbles(numel(wholeImagesToOcclude), targetImageSize, bubblesPerImage, bubbleSize);
disp('occluding images...');
[occludedImages, imagesVisible] = prepareOccludeImages(...
    wholeImagesToOcclude, backgroundMasks, gray, numBubbles, bubbleCenters, bubbleSigmas);

%% save
fprintf('saving...\n');
black = 100 - imagesVisible;
bubble_centers = bubbleCenters; nbubbles = numBubbles;
data = table(occluded, bubble_centers, bubbleSigmas, nbubbles, ...
    black, imagesVisible);

save(sprintf('%s/data.mat', targetDirectory), 'images', 'data');
occludedFilenames = arrayfun(@num2str, wholeImageNumsToOcclude, 'UniformOutput', false);
saveImages([targetDirectory, '/occluded/'], occludedImages, occludedFilenames);
wholeFilenames = arrayfun(@num2str, wholeImageNumsToOcclude, 'UniformOutput', false);
saveImages([targetDirectory, '/whole/'], images, wholeFilenames);
end

function croppedImage = resizedCenterCrop(image, targetSize)
imageSize = size(image);
scale = max(targetSize ./ imageSize(1:2));
resizedImage = imresize(image, scale);
imageSize = size(resizedImage);

cropXY = (imageSize(1:2) - targetSize) / 2;
cropSize = targetSize;
if cropXY(1) > cropXY(2)
    cropSize = cropSize - [1, 0];
else
    cropSize = cropSize - [0, 1];
end
croppedImage = imcrop(resizedImage, cat(2, fliplr(cropXY), fliplr(cropSize)));
imageSize = size(croppedImage);
assert(all(imageSize(1:2) == targetSize));
end
