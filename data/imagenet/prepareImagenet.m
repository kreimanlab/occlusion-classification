function data = prepareImagenet(imagesDirectory, targetDirectory, occludedWholeRatio)
%PREPAREIMAGENET prepares the data for fine-tuning (mixed training)
%   occludedWholeRatio: number of occluded images to train on divided by 
%   number of whole images to train on

imagesDirectory = char(imagesDirectory); targetDirectory = char(targetDirectory);
scriptDirectory = fileparts(mfilename('fullpath'));
assert(exist('imagesDirectory', 'var') == 1);
if ~exist('targetDirectory', 'var')
    targetDirectory = [scriptDirectory, '/processed_images/'];
end
mkdir(targetDirectory);
fprintf('running with imagesDirectory=%s, targetDirectory=%s\n', ...
    imagesDirectory, targetDirectory);

%% settings
if ~exist('occludedWholeRatio', 'var')
    occludedWholeRatio = 1/1;
end
% TODO: this is different from the original 256x256, so make sure to keep
% occlusion distribution equal
targetImageSize = [227, 227];
convertGrayscale = false;
gray = 128;
bubblesPerImage = 5;
bubbleSize = 14;
fprintf('using bubble size %d\n', bubbleSize);
rng(0, 'twister');

%% read images
fprintf('collecting images...\n');
images = cell(0);
relativeImagePaths = cell(0);
count = 0;
errors = 0;
subDirectories = dir(imagesDirectory);
subDirectories = {subDirectories.name};
subDirectories(ismember(subDirectories, {'.', '..'})) = [];
for dirCounter = 1:numel(subDirectories)
    subDirectory = subDirectories{dirCounter};
    fprintf('Directory %d/%d: %s\n', dirCounter, numel(subDirectories), subDirectory);
    imagesSubDirectory = [imagesDirectory, '/', subDirectory];
    imageFiles = dir([imagesSubDirectory, '/*.JPEG']);
    for i = 1:numel(imageFiles)
        imagePath = [imagesSubDirectory, '/', imageFiles(i).name];
        try
            image = imread(imagePath);
        catch e
            msgText = getReport(e);
            warning(msgText);
            errors = errors + 1;
            continue;
        end
        image = resizedCenterCrop(image, targetImageSize);
        if convertGrayscale && isRgb(image)
            image = rgb2gray(image);
        end
        images{end + 1} = image;
        relativeImagePaths{end + 1} = relativepath(fullfile(pwd, imagePath), fullfile(pwd, imagesDirectory));
        relativeImagePaths{end} = relativeImagePaths{end}(3:end - 1);
        count = count + 1;
    end
end
images = images'; relativeImagePaths = relativeImagePaths';
fprintf('Found %d images\n', count);
fprintf('%d images failed to read\n', errors);
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
fprintf('saving data...\n');
black = 100 - imagesVisible;
bubble_centers = bubbleCenters; nbubbles = numBubbles;
data = table(occluded, bubble_centers, bubbleSigmas, nbubbles, ...
    black, imagesVisible);
save(sprintf('%s/data.mat', targetDirectory), 'images', 'data');

fprintf('saving images...\n');
wholeFilenames = arrayfun(@(i) relativeImagePaths{i}, wholeImageNumsToOcclude, 'UniformOutput', false);
% TODO: the following is not going to work for non-1:1 ratios
occludedFilenames = arrayfun(@(i) adjustFilenameOcclusion(relativeImagePaths{i}), wholeImageNumsToOcclude, 'UniformOutput', false);
saveImages(targetDirectory, images, wholeFilenames);
saveImages(targetDirectory, occludedImages, occludedFilenames);
end

function occlusionFilename = adjustFilenameOcclusion(filepath)
[path, name, ext] = fileparts(filepath);
occlusionFilename = [path, '/', name, '-occluded', ext];
end

function croppedImage = resizedCenterCrop(image, targetSize)
imageSize = size(image);
scale = max(targetSize ./ imageSize(1:2));
resizedImage = imresize(image, scale);
imageSize = size(resizedImage);

cropXY = round((imageSize(1:2) - targetSize) / 2);
cropSize = targetSize;
if cropXY(1) > 0
    cropSize = cropSize - [1, 0];
end
if cropXY(2) > 0
    cropSize = cropSize - [0, 1];
end % nothing to do for x=y=0
croppedImage = imcrop(resizedImage, cat(2, fliplr(cropXY), fliplr(cropSize)));
imageSize = size(croppedImage);
assert(all(imageSize(1:2) == targetSize));
end
