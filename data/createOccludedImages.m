function createOccludedImages

%% Setup
% bubbles
bub_sig = 14;
% load data
dir = fileparts(mfilename('fullpath'));
imagesData = load([dir '/KLAB325.mat']);
originalImages = imagesData.img_mat;
occlusionDataFile = [dir '/data_occlusion_klab325v2.mat'];
load(occlusionDataFile);
% output
outputFile = [dir '/KLAB325-occluded.mat'];

%% Run
img_mat = cell(1, length(originalImages));
for i = 1:length(originalImages)
    disp(['image #' num2str(i)])
    image = originalImages{i};
    numBubbles = data.nbubbles(i);
    c = data.bubble_centers(i, 1:numBubbles);
    
    S.c = c;
    S.sig = bub_sig * ones(1,numBubbles);
    [occludedImage,~] = AddBubble(image, S);
    img_mat{i} = occludedImage;
    % imwrite(occludedImage, ['./images-occluded/im_' num2str(i) '.tif']);
end
save(outputFile, 'img_mat');
