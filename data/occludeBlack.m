function occludedImage = occludeBlack(pres, black, showImage)
if ~exist('showImage', 'var')
    showImage = true;
end

data = load('data/data_occlusion_klab325v2.mat');
data = data.data;
data = data(data.pres == pres, :);
[~, row] = min(abs(data.black - black));
occludedImage = createOccludedImage(row, showImage);
end
