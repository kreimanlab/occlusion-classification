function writeImagesFromMat(imageSize)
directory = fileparts(mfilename('fullpath'));
occludedDir = [directory, '/occluded'];
mkdir(occludedDir);
images = load('data/KLAB325.mat');
images = images.img_mat;
data = load('data/data_occlusion_klab325v2.mat');
data = data.data;
bubbleSigmas = repmat(14, [size(data, 1), 10]);
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
    for i = indices
        %% whole
        baseImage = images{i};
        image = convertImage(baseImage, imageSize);
        imageBasename = sprintf('%03d', i);
%         imwrite(image, [categoryDir, '/', imageBasename, '.png']);
        %% occluded
        dataSelection = find(data.pres == i)';
        assert(unique(data.truth(dataSelection)) == c);
        for row = dataSelection
            occludedImage = occlude({baseImage}, data.nbubbles(row), ...
                data.bubble_centers(row, :), bubbleSigmas(row, :));
            occludedImage = convertImage(occludedImage{1}, imageSize);
            filepath = [occludedCategoryDir, '/', imageBasename, ...
                '-', sprintf('%d', row), '.png'];
%             imwrite(occludedImage, filepath);
        end
    end
end
end

function image = convertImage(baseImage, imageSize)
image = imresize(baseImage, [imageSize, imageSize]);
image = grayscaleToRgb(image, 'channels-last');
end