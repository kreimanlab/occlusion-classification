function maxValues = maxFilter(img,poolSize)
% maxValues = maxFilter(img,poolSize)
%
% given an image and pooling range, returns a matrix of the image's maximum
% values in each neighborhood defined by the pooling range
%
% args:
%
%     img: a 2-dimensional matrix, the image to be filtered
%
%     poolSize: a scalar, P, such that each maximum will be taken over a PxP
%     area of pixels
%
% returns:
%
%     maxValues: a matrix whose size depends on poolSize, contains the maximum
%     values found in poolSize x poolSize areas across img.

    [nRows nCols] = size(img);
    halfpool = poolSize/2;
    rowIndices = 1:halfpool:nRows;
    colIndices = 1:halfpool:nCols;
    maxValues = zeros(size(rowIndices,2),size(colIndices,2));

    rCount = 1;
    for r = rowIndices
        cCount = 1;
        for c = colIndices
            maxValues(rCount,cCount) = max(max(img(r:min(r+poolSize-1,nRows),...
                                                   c:min(c+poolSize-1,nCols))));
            cCount = cCount+1;
        end
        rCount = rCount+1;
    end
end
