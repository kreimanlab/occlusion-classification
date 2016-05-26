function distances = windowedPatchDistance(c1Img,patch,ALLS2C1PRUNE,ORIENTATIONS2C1PRUNE)
% distances = windowedPatchDistance(c1Img,patch)
% 
% given an image and patch, computes the euclidean distance between the patch
% and all crops of an image's C1 representation of similar size.
%
% args:
%
%     c1Img: a 3-dimensional matrix, an image representation in C1-space.
%
%     patch: a 3-dimensional matrix, the patch to match windows against.
%     c1Img and patch must have the same depth, as each layer represents one
%     orientation.
%
%     ALLS2C1PRUNE: a scalar with the range [0,1], indicates the amount of
%     pruning to conduct across the entire patch. If 0, no pruning is done.
%
%     ORIENTATIONS2C1PRUNE: a scalar with the range [0,1], indicates the amount
%     of pruning to conduct across each orientation of the patch. If 0, no
%     pruning is done.
%
% returns:
%
%     distances: a size(c1Img,1) x size(c1Img,2) matrix, marking the euclidean
%     distance between the patch and the C1-space representation of an image.
%     Each entry marks the distance between the patch and the image's C1
%     activations centered at that location.
%
% note: sumOverP(W(p)-I(p))^2 is computed as
%       sumOverP(W(p)^2) - 2*(W(p)*I(p)) + sumOverP(I(p)^2);

    c1ImgDepth = size(c1Img,3);
    patchDepth = size(patch,3);
    assert((c1ImgDepth == patchDepth), 'windowedP...m: patch and c1Img depth differ\n');

    if (nargin < 4) ORIENTATIONS2C1PRUNE = 0; end;
    if (nargin < 3) ALLS2C1PRUNE = 0; end;

    if ALLS2C1PRUNE
        rmin = min(min(min(patch(:,:,:))));
        rmax = max(max(max(patch(:,:,:))));
        allS2C1prune = rmin + ALLS2C1PRUNE * (rmax-rmin);
        if ORIENTATIONS2C1PRUNE
            rmin = min(patch(:,:,:),[],3);
            rmax = max(patch(:,:,:),[],3);
            orientationS2C1prune = rmin + ORIENTATIONS2C1PRUNE * (rmax-rmin);
        end
    end

    if ALLS2C1PRUNE
        keepP(:,:,:) = patch(:,:,:) >= allS2C1prune;
        if ORIENTATIONS2C1PRUNE
            for i=1:patchDepth
                keepP(:,:,i) = keepP(:,:,i) & (patch(:,:,i) >= orientationS2C1prune);
            end
        end
    else
        keepP = ones(size(patch));
    end

    patchSquaredSum = sum(sum(sum(keepP .* patch.^2)));

    patchSize = size(patch);
    sumSupport = [ceil(patchSize(2)/2)-1,ceil(patchSize(1)/2)-1,...
                  floor(patchSize(2)/2),floor(patchSize(1)/2)];
    c1ImgSquared = c1Img.^2;
    c1ImgSquared = sum(c1ImgSquared,3);
    c1ImgSquared = sumFilter(c1ImgSquared,sumSupport);

    patchXc1Img = zeros(size(c1ImgSquared));
    for i = 1:c1ImgDepth
        tmpPatch = flipud(fliplr(double(patch(:,:,i)))); % flipped for conv2
        patchXc1Img = patchXc1Img + conv2(c1Img(:,:,i),keepP(:,:,i) .* tmpPatch, 'same');
    end

    distancesSquared = c1ImgSquared - 2*patchXc1Img + patchSquaredSum;
    distancesSquared(distancesSquared < 0) = 0;
    distances = sqrt(distancesSquared) + 10^-10;
end
