function occludedImage = createOccludedImage(row, showImage)
if ~exist('showImage', 'var')
    showImage = true;
end

data = load('data/data_occlusion_klab325v2.mat');
data = data.data;
image = load('data/KLAB325.mat');
image = image.img_mat{data.pres(row)};
bub_sig = 14;
numBubbles = data.nbubbles(row);
S.c = data.bubble_centers(row, 1:numBubbles);
S.sig = bub_sig * ones(1, numBubbles);
occludedImage = AddBubble(image, S);
if showImage
    figure();
    imshow(occludedImage);
end
end
