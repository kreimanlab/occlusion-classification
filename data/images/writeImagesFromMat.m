function writeImagesFromMat(imageSize)
directory = fileparts(mfilename('fullpath'));
occludedDir = [directory, '/occluded'];
mkdir(occludedDir);
lessOccludedDir = [directory, '/lessOccluded'];
mkdir(lessOccludedDir);

images = load('data/KLAB325.mat');
images = images.img_mat;
occlusionData = load('data/data_occlusion_klab325v2.mat');
occlusionData = occlusionData.data;
lessOcclusionData = load('data/lessOcclusion/data_occlusion_klab325-high_visibility.mat');
lessOcclusionData = lessOcclusionData.data;

bubbleSigmas = repmat(14, [size(occlusionData, 1), 10]);
if ~exist('imageSize', 'var')
    imageSize = size(images{1}, 2);
end

categories = {
    'animal', [1:60, 301:305]; ...
    'chair', [61:120, 306:310]; ...
    'face', [121:180, 311:315]; ...
    'fruit', [181:240, 316:320]; ...
    'vehicle', [241:300, 321:325]
    };

for c = 1:size(categories, 1)
    category = categories{c, 1};
    indices = categories{c, 2};
    assert(numel(indices) == numel(images) / size(categories, 1));
    
    categoryDir = [directory, '/', category];
    mkdir(categoryDir);
    occludedCategoryDir = [occludedDir, '/', category];
    mkdir(occludedCategoryDir);
    lessOccludedCategoryDir = [lessOccludedDir, '/', category];
    mkdir(lessOccludedCategoryDir);
    for i = indices
        %% whole
        baseImage = images{i};
        image = convertImage(baseImage, imageSize);
        imageBasename = sprintf('%03d', i);
        imwrite(image, [categoryDir, '/', imageBasename, '.png']);
        %% occluded
        occlusionDataSelection = find(occlusionData.pres == i)';
        assert(unique(occlusionData.truth(occlusionDataSelection)) == c);
        for row = occlusionDataSelection
            occludedImage = occlude({baseImage}, occlusionData.nbubbles(row), ...
                occlusionData.bubble_centers(row, :), bubbleSigmas(row, :));
            occludedImage = convertImage(occludedImage{1}, imageSize);
            filepath = [occludedCategoryDir, '/', imageBasename, ...
                '-', sprintf('%d', row), '.png'];
            imwrite(occludedImage, filepath);
        end
        %% less-occluded
        lessOcclusionDataSelection = find(lessOcclusionData.pres == i)';
        assert(unique(lessOcclusionData.truth(lessOcclusionDataSelection)) == c);
        for row = lessOcclusionDataSelection
            lessOccludedImage = occlude({baseImage}, lessOcclusionData.nbubbles(row), ...
                lessOcclusionData.bubble_centers(row, :), ...
                lessOcclusionData.bubbleSigmas(row, :));
            lessOccludedImage = convertImage(lessOccludedImage{1}, imageSize);
            filepath = [lessOccludedCategoryDir, '/', imageBasename, ...
                '-', sprintf('%d', row), '.png'];
            imwrite(lessOccludedImage, filepath);
        end
    end
end
end

function image = convertImage(baseImage, imageSize)
image = imresize(baseImage, [imageSize, imageSize]);
image = grayscaleToRgb(image, 'channels-last');
end