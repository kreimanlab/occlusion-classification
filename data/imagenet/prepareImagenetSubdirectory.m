function data = prepareImagenetSubdirectory(imagesSubDirectory, targetSubDirectory, occludedWholeRatio)
    if ~exist('occludedWholeRatio', 'var')
        occludedWholeRatio = 1/1;
    end
    fprintf('Running with source dir=%s, target dir=%s, ratio=%f\n', ...
        imagesSubDirectory, targetSubDirectory, occludedWholeRatio);
    imagesSubDirectory = char(imagesSubDirectory); targetSubDirectory = char(targetSubDirectory);
    % TODO: this is different from the original 256x256, so make sure to keep
    % occlusion distribution equal
    targetImageSize = [227, 227];
    convertGrayscale = false;
    gray = 128;
    bubblesPerImage = 5;
    bubbleSize = 14;
    [~, targetDirName] = fileparts(targetSubDirectory);
    dirNumberSortOfHash = mod(sum(1 + lower(targetDirName - 'a')), 2^32);
    fprintf('Seeding with %d\n', dirNumberSortOfHash);
    rng(dirNumberSortOfHash, 'twister');
    
    if exist(targetSubDirectory, 'dir') ~= 7
        mkdir(targetSubDirectory);
    end
    
    %% collect
    fprintf('collecting images...\n');
    count = 0;
    errors = 0;
    imageFiles = dir([imagesSubDirectory, '/*.JPEG']);
    images = cell(size(imageFiles));
    relativeImagePaths = cell(size(imageFiles));
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
        images{i} = image;
        relativeImagePaths{i} = relativepath(fullfile(pwd, imagePath), fullfile(pwd, imagesSubDirectory));
        relativeImagePaths{i} = relativeImagePaths{i}(3:end - 1);
        count = count + 1;
    end
%     images = images'; relativeImagePaths = relativeImagePaths';
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
    save(sprintf('%s/data.mat', targetSubDirectory), 'data');

    fprintf('saving images (%d whole, %d occluded)...\n', numel(images), numel(occludedImages));
    wholeFilenames = arrayfun(@(i) relativeImagePaths{i}, wholeImageNumsToOcclude, 'UniformOutput', false);
    % TODO: the following is not going to work for non-1:1 ratios
    occludedFilenames = arrayfun(@(i) adjustFilenameOcclusion(relativeImagePaths{i}), wholeImageNumsToOcclude, 'UniformOutput', false);
    saveImages(targetSubDirectory, images, wholeFilenames);
    saveImages(targetSubDirectory, occludedImages, occludedFilenames);
    fprintf('Saved to %s\n', targetSubDirectory);
end

function occlusionFilename = adjustFilenameOcclusion(filepath)
[path, name, ext] = fileparts(filepath);
if ~isempty(path)
    path = [path, '/'];
end
occlusionFilename = [path, name, '-occluded', upper(ext)];
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
