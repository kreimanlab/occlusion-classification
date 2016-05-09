function createOccludedImages

%% Setup
% bubbles
bub_sig = 14;
% load data
dir = fileparts(mfilename('fullpath'));
imagesData = load([dir '/KLAB325.mat']);
originalImages = imagesData.img_mat;
occlusionDataFile = [dir '/data_occlusion_main.mat'];
load(occlusionDataFile);
% output
outputDirectory = [dir '/images-occluded/'];
if ~exist(outputDirectory, 'dir')
    mkdir(outputDirectory);
end

%% Run
for i = 1:length(originalImages)
    disp(['image #' num2str(i)])
    im = originalImages{i};
    numBubbles = data.nbubbles(i);
    c = data.bubble_centers(i, 1:numBubbles);
    
    S.c = c;
    S.sig = bub_sig * ones(1,numBubbles);
    [im,~] = AddBubble(im, S);
    imwrite(im, [outputDirectory 'im_' num2str(i) '.tif']);
end
