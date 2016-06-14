function occludedImage = occludeBlack(pres, black)
image = load('data/KLAB325.mat');
image = image.img_mat{pres};
data = load('data/data_occlusion_klab325v2.mat');
data = data.data;
data = data(data.pres == pres, :);
[~, idx] = min(abs(data.black - black));
fprintf('Using %.2f%% occlusion\n', data.black(idx));
bub_sig = 14;
numBubbles = data.nbubbles(idx);
S.c = data.bubble_centers(idx, 1:numBubbles);
S.sig = bub_sig * ones(1, numBubbles);
occludedImage = AddBubble(image, S);
figure();
imshow(occludedImage);
end
