function data = prepareImagenet(imagesDirectory)
directory = fileparts(mfilename('fullpath'));
if ~exist('imagesDirectory', 'var')
    imagesDirectory = [directory, '/images'];
end
imageSize = [500, 343];
bubblesPerImage = 5;
bubbleSize = 14;
rng(0, 'twister');

disp('collecting images and truths...');
truths = load('ground_truths.mat');
truths = truths.truths;
files = dir([imagesDirectory, '/*.JPEG']);
assert(numel(fieldnames(truths)) == size(files, 1));

labels = NaN(numel(truths), 1);
images = cell(size(files));
for i = 1:numel(files)
    if mod(i - 1, 1000) == 0 || i == numel(files)
        fprintf('%d/%d\n', i, numel(files));
    end
    labels(i) = str2num(truths.(files(i).name));
    try
        images{i} = imread([imagesDirectory, '/', files(i).name]);
        if isRgb(images{i})
            images{i} = rgb2gray(images{i});
        end
    catch err
        warning('Error with image %d: %s', i, getReport(err));
    end
end

disp('creating bubbles...');
[numBubbles, bubbleCenters, bubbleSigmas] = ...
    createBubbles(numel(labels), imageSize, bubblesPerImage, bubbleSize);

saveFile = [directory, '/../Imagenet.mat'];
disp('saving...');
data = table(labels, numBubbles, bubbleCenters, bubbleSigmas);
data = table2dataset(data); % might not run on older versions otherwise
save(saveFile, 'images', 'data', '-v7.3');
end
