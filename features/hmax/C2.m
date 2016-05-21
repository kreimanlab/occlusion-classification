function [c2,s2,c1,s1,bestBands,bestLocations] = C2(img,filters,filterSizes,c1Space,c1Scale,c1OL,linearPatches,patchSize,c1,IGNOREPARTIALS,ALLS2C1PRUNE,ORIENTATIONS2C1PRUNE)
% [c2,s2,c1,s1,bestBands,bestLocations] = C2(img,filters,filterSizes,c1Space,c1Scale,c1OL,linearPatches,patchSize,c1,IGNOREPARTIALS,ALLS2C1PRUNE,ORIENTATIONS2C1PRUNE)
%
% Given an image, filters, & patches, returns S1, C1, S2, & C2 unit responses.
%
% args:
%
%     img: a 2-dimensional matrix, the input image must be grayscale and of
%     type 'double'
%
%     filters, filterSizes, c1Space, c1Scale, C1OL: see C1.m
%
%     linearPatches: a 2-dimensional matrix, the prototypes (patches) used in
%     the extraction of s2. Each patch of size [m,n,d] is stored as a column in
%     linearPatches, which has itself a size of [m*n*d, n_patches];
%
%     patchSize: a 3-element vector, [m n d], describing the size of each patch
%     in 'linearPatches'. m is the number of rows, n the number of columns, and
%     d the number of orientations.
%
%     c1: a precomputed c1 layer can be used to save computation time if
%     available.  The proper format is the output of C1.m
%
%     IGNOREPARTIALS: a logical, if true, "partial" activations will be
%     ignored, and only filter and patch activations completely on the image
%     will be used. If false, all S2 activations are used.
%
%     ALLS2C1PRUNE, ORIENTATIONS2C1PRUNE: scalars, see windowedPatchDistance.m
%
% returns:
%
%     c2: a matrix [nPatches 1], contains the C2 responses for img
%
%     s2: a cell array [nPatches 1], contains the S2 responses for img
%
%     c1,s1: cell arrays, see C1.m
%
% See also C1 (C1.m)

    s1 = []; % required for cached c1 activations
    if (nargin < 12) ORIENTATIONS2C1PRUNE = 0; end;
    if (nargin < 11) ALLS2C1PRUNE = 0; end;
    if (nargin < 10) IGNOREPARTIALS = 0; end;
    if (nargin <  9 || isempty(c1)) [c1,s1] = C1(img,filters,filterSizes,c1Space,c1Scale,c1OL,0); end;

    c1BandImg = c1;
    nBands = length(c1);
    nOrientations = patchSize(3);
    nPatchRows = patchSize(1);
    nPatchCols = patchSize(2);
    nPatches = size(linearPatches,2);

    % Build s2:
    s2 = cell(nPatches,1);
    for iPatch = 1:nPatches
        squarePatch = reshape(linearPatches(:,iPatch),patchSize);
        s2{iPatch} = cell(nBands,1);
        for iBand = 1:nBands
            s2{iPatch}{iBand} = windowedPatchDistance(c1BandImg{iBand},squarePatch,ALLS2C1PRUNE,ORIENTATIONS2C1PRUNE);  
        end
    end

    % Build c2:
    c2 = inf(1,nPatches);
    for iPatch = 1:nPatches
        for iBand = 1:nBands
            [nRows, nCols] = size(s2{iPatch}{iBand});
            if IGNOREPARTIALS
                ignorePartials = inf(nRows,nCols);
                [nRowsImg, nColsImg] = size(img);
                poolRange = c1Space(iBand);
                maxFilterRows = 1:poolRange/2:nRowsImg;
                maxFilterCols = 1:poolRange/2:nColsImg;
                invalidS1Pre = ceil(filterSizes(c1Scale(iBand)*nOrientations)/2);
                invalidS1Post = floor(filterSizes(c1Scale(iBand)*nOrientations)/2);
                rMin = ceil(nPatchRows/2)+sum(ismember(maxFilterRows,1:invalidS1Pre));
                rMax = nRows-floor(nPatchRows/2)-sum(ismember(maxFilterRows,(nRowsImg-(invalidS1Post+poolRange-1)):nRowsImg)); 
                cMin = ceil(nPatchCols/2)+sum(ismember(maxFilterCols,1:invalidS1Pre));
                cMax = nCols-floor(nPatchCols/2)-sum(ismember(maxFilterCols,(nColsImg-(invalidS1Post+poolRange-1)):nColsImg));
                if rMin < rMax && cMin < cMax
                    ignorePartials(rMin:rMax,cMin:cMax) = s2{iPatch}{iBand}(rMin:rMax,cMin:cMax);
                end
                [minValue minLocation] = min(ignorePartials(:));
            else
                [minValue minLocation] = min(s2{iPatch}{iBand}(:));
            end
            if minValue < c2(iPatch)
                c2(iPatch) = minValue;
                bestBands(iPatch) = iBand;
                [bestLocations(iPatch,1) bestLocations(iPatch,2)] = ind2sub([nRows,nCols], minLocation);
            end
        end
    end
end
