function occludedImage = occludeBlack(imageNum, black)
image = load('data/KLAB325.mat');
image = image.img_mat{imageNum};
data = load('data/data_occlusion_klab325v2.mat');
data = data.data;
[~, idx] = min(abs(data.black - black));
bub_sig = 14;
numBubbles = data.nbubbles(idx);
S.c = data.bubble_centers(idx, 1:numBubbles);
S.sig = bub_sig * ones(1, numBubbles);
occludedImage = AddBubble(image, S);
figure();
imshow(occludedImage);
end
