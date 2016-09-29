function [numBubbles, bubbleCenters, bubbleSigmas, occluded] = ...
    createBubbles(numImages, imageSize, ...
    numBubbles, bubbleSigma, ratioOccluded)
%CREATEBUBBLES create centers and sigmas for Gaussian bubbles.
if ~exist('ratioOccluded', 'var')
    ratioOccluded = 1;
end
numBubbles = repmat(numBubbles, [numImages, 1]);
numBubbles(randperm(numImages, ceil(numImages * (1 - ratioOccluded)))) = 0;
occluded = numBubbles > 0;
bubbleCenters = NaN(numImages, max(numBubbles(:)));
bubbleSigmas = NaN(numImages, max(numBubbles(:)));
for i = 1:numImages
    bubbleCenters(i, 1:numBubbles(i)) = ...
        ceil(prod(imageSize) * rand(1, numBubbles(i)));
    if ~isvector(bubbleSigma)
        sigma = bubbleSigma;
    else
        sigma = bubbleSigma(randsample(numel(bubbleSigma), 1));
    end
    bubbleSigmas(i, 1:numBubbles(i)) = ...
        sigma * ones(1, numBubbles(i));
end
end
