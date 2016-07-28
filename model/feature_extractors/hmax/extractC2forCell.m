function [c2,c1,bestBands,bestLocations,s2,s1] = extractC2forCell(filters,filterSizes,c1Space,c1Scale,c1OL,linearPatches,imgs,nPatchSizes,patchSizes,ALLS2C1PRUNE,c1,ORIENTATIONS2C1PRUNE,IGNOREPARTIALS)
% [c2,c1,bestBands,bestLocations,s2,s1] = extractC2forCell(filters,filterSizes,c1Space,c1Scale,c1OL,linearPatches,imgs,nPatchSizes,patchSizes,ALLS2C1PRUNE,c1,ORIENTATIONS2C1PRUNE,IGNOREPARTIALS)
%
% For each image in 'imgs', extract all responses.
%
% args:
%
%     imgs: a cell array of matrices, each representing an image
%
%     filters,filterSizes: see initGabor.m
%
%     c1Space,c1Scale,c1OL: see C1.m
%
%     linearPatches: a cell array with 1 cell/patchSize, each cell holds an
%         patchSizeX * patchSizeY * nOrientations x nPatchesPerSize matrix
%
%     nPatchSizes: size(patchSizes,2) - kept only for backward compatibility
%
%     patchSizes: a 3 x nPatchSizes array of patch sizes 
%     Each column should hold [nRows; nCols; nOrients]
%
%     c1: a precomputed set of C1 responses, as output by C1.m
%
%     IGNOREPARTIALS: see C2.m
%
%     ALLS2C1PRUNE,ORIENTATIONS2C1PRUNE: see windowedPatchDistance.m
%
% returns: 
%
%     c2: a 1 x nPatchSizes cell array. Each cell is nPatches x nImgs array 
%     holding C2 activations.
%
%     s2,c1,s1: cell arrays holding the particular s2, c1, or s1 response for
%     each image, see C2.m, C1.m
%
%     bestBands: a 1 x nPatchSizes cell array. Each cell is nPatches x nImgs array, 
%     the band whence came the maximal response for each patch and image.
%
%     bestLocations: a 1 x nPatchSizes cell array. Each cell is nPatches x nImgs x 2 array, 
%     the (x,y) pair whence came the maximal response for each patch and image.

    nImgs = length(imgs);
    nPatchSizes = size(patchSizes,2);
    nPatchesPerSize = size(linearPatches{1},2);
    nPatches = nPatchSizes*nPatchesPerSize;

    if (nargin < 13) IGNOREPARTIALS = 0; end;
    if (nargin < 12) ORIENTATIONS2C1PRUNE = 0; end;
    if (nargin < 11 || isempty(c1)) c1 = cell(1,nImgs); end;
    if (nargin < 10) ALLS2C1PRUNE = 0; end;

    c2            = cell(1,nPatchSizes);
    bestBands     = cell(1,nPatchSizes);
    bestLocations = cell(1,nPatchSizes);
    for i = 1:nPatchSizes
        c2{i}            = zeros(nPatchesPerSize,nImgs);
        bestBands{i}     = zeros(nPatchesPerSize,nImgs);
        bestLocations{i} = zeros(nPatchesPerSize,nImgs,2);
    end
    s2 = cell(1,nImgs);
    s1 = cell(1,nImgs);
    
    for iImg = 1:nImgs
        iImg % outputs the variable to track the progress.
        for iPatchSize = 1:nPatchSizes
            iPatchSize % outputs the variable to track the progress.
            patchIndices = 1:nPatchesPerSize;
            if isempty(c1{iImg}),  %compute C1 & S1
                [c2{iPatchSize}(patchIndices,iImg),s2{iImg}{iPatchSize},c1{iImg},s1{iImg},bestBands{iPatchSize}(patchIndices,iImg),bestLocations{iPatchSize}(patchIndices,iImg,:)] =...
                C2(imgs{iImg},filters,filterSizes,c1Space,c1Scale,c1OL,linearPatches{iPatchSize},patchSizes(:,iPatchSize)',[],IGNOREPARTIALS,ALLS2C1PRUNE,ORIENTATIONS2C1PRUNE);
            else
                [c2{iPatchSize}(patchIndices,iImg),s2{iImg}{iPatchSize},~,~,bestBands{iPatchSize}(patchIndices,iImg),bestLocations{iPatchSize}(patchIndices,iImg,:)] =...
                C2(imgs{iImg},filters,filterSizes,c1Space,c1Scale,c1OL,linearPatches{iPatchSize},patchSizes(:,iPatchSize)',c1{iImg},IGNOREPARTIALS,ALLS2C1PRUNE,ORIENTATIONS2C1PRUNE);
            end
        end
    end
end
