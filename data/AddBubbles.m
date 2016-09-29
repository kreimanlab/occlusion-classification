function [bubbledImage, mask] = ...
    AddBubbles(img, bubbleCenters, bubbleSigmas, color)
% centers are indexed over numel(img)
myeps = 10^-8;
bubbledImage = double(img);
mask = zeros(size(img));
[y, x] = ndgrid(1:size(img, 1), 1:size(img, 2));
[yc, xc] = ind2sub(size(img), bubbleCenters);
for i = 1:length(xc)
    maskt = exp(- ((x - xc(i)).^2 + (y - yc(i)).^2) / 2 / bubbleSigmas(i)^2);
    maskt = maskt / max(maskt(:));
    mask = max(mask, maskt);
end
mask(mask < myeps) = 0;

foreground = color / 255;
m = max(255, max(bubbledImage(:)));
bubbledImage = bubbledImage / m - foreground;
bubbledImage = bubbledImage .* mask + foreground;
bubbledImage = uint8(bubbledImage * 255);
end
