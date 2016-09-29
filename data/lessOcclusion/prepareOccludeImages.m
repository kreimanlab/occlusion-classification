function [occludedImages, imageVisible, backgroundVisible] = ...
    prepareOccludeImages(images, backgroundMasks, color, ...
    numBubbles, bubbleCenters, bubbleSigmas)
occludedImages = cell(size(images));
imageVisible = NaN(size(images));
backgroundVisible = NaN(size(images));
for i = 1:numel(images)
    nBubbles = numBubbles(i);
    if nBubbles > 0
        [occludedImages{i}, bubbleMask] = AddBubbles(images{i}, ...
            bubbleCenters(i, 1:nBubbles), bubbleSigmas(i, 1:nBubbles), ...
            color);
    else
        occludedImages{i} = images{i};
        bubbleMask = ones(size(occludedImages{i}));
    end
    [imageVisible(i), backgroundVisible(i)] = ...
        getPercentVisible(backgroundMasks{i}, bubbleMask);
end
end

function [imageVisible, backgroundVisible] = ...
    getPercentVisible(imageMask, bubbleMask)
imagePixelVisibility = imageMask;
% 2sd = 0.134 3sd = 0.01 1sd = 0.6
outside2StandardDeviations = bubbleMask < 0.134;
imagePixelVisibility(outside2StandardDeviations) = 0;
imageVisible = 100 * sum(imagePixelVisibility(:)) / sum(imageMask(:));
backgroundVisible = ...
    100 * sum(~imagePixelVisibility(:)) / sum(~imageMask(:));
end

function [imageVisible, backgroundVisible] = ...
    getPercentVisiblePrecise(imageMask, bubbleMask)
imagePixelVisibility = double(imageMask) .* bubbleMask;
backgroundPixelVisibility = double(~imageMask) .* bubbleMask;
imageVisible = 100 * sum(imagePixelVisibility(:)) / sum(imageMask(:));
backgroundVisible = ...
    100 * sum(backgroundPixelVisibility(:)) / sum(~imageMask(:));
end
