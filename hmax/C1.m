function [c1,s1] = C1(img,filters,filterSizes,c1Space,c1Scale,c1OL,INCLUDEBORDERS)
% function [c1,s1] = C1(img,filters,filterSizes,c1Space,c1Scale,c1OL,INCLUDEBORDERS)
%
% Given an image, returns C1 & S1 unit responses
%
% args:
%
%     img: a 2-dimensional matrix, the input image must be grayscale and of
%     type 'double'
%
%     filters: (for S1 units) a matrix of Gabor filters of size max_filterSizes
%     x nFilters, where max_filterSizes is the length of the largest filter &
%     nFilters is the total number of filters. Column j of 'filters' contains a
%     n_jxn_j filter, reshaped as a column vector and padded with zeros. n_j =
%     filterSizes(j).
%
%     filterSizes: (for S1 units) a vector, contains filter sizes.
%     filterSizes(i) = n if filters(i) is n x n (see 'filters' above).
%
%     c1Scale: (for C1 units) a vector, defines the scale bands, a group of
%     filter sizes over which a local max is taken to get C1 unit responses.
%     ex. c1Scale = [1 k num_filters+1] means 2 bands, the first with
%     filters(:,1:k-1) and the second with filters(:,k:num_filters). If N
%     bands, make length(c1Scale) = N+1.
%
%     c1Space: (for C1 units) a vector, defines the spatial pooling range of
%     each scale band, ex. c1Space(i) = m means that each C1 unit response in
%     band i is obtained by taking a max over a neighborhood of m x m S1 units.
%     If N bands, make length(c1Space) = N.
%
%     c1OL: (for C1 units) a scalar, defines the overlap between C1 units.
%     In scale band i, C1 unit responses are computed every c1Space(i)/c1OL.
%
%     INCLUDEBORDERS: scalar, defines border treatment for 'img'.
%
% returns:
%
%     c1: a cell array [1 nBands], contains the C1 responses for img
%
%     s1: a cell array [1 nBands], contains the S1 responses for img

    USECONV2 = 1; % should be faster if 1.
    if(nargin < 7) INCLUDEBORDERS = 1; end;

    nBands=length(c1Scale)-1;
    nScales=c1Scale(end)-1; % remember, last element in c1Scale is max scale + 1
    nFilters=floor(length(filterSizes)/nScales);
    scalesInThisBand=cell(1,nBands);
    for iBand = 1:nBands
        scalesInThisBand{iBand} = c1Scale(iBand):(c1Scale(iBand+1) -1);
    end

    % rebuild all filters (of all sizes) %
    nFilts = length(filterSizes);
    for i = 1:nFilts
        sqfilter{i} = reshape(filters(1:(filterSizes(i)^2),i),filterSizes(i),filterSizes(i));
        if USECONV2 % flip to use conv2 instead of imfilter
            sqfilter{i} = sqfilter{i}(end:-1:1,end:-1:1);
        end
    end

    % compute all filter responses (s1) %

    % (1) precalculate normalizations for the usable filter sizes
    imgSquared = img.^2;
    uFilterSizes = unique(filterSizes)';
    for iFilterSize = uFilterSizes
        s1Norm{iFilterSize} = (sumFilter(imgSquared,(iFilterSize-1)/2)).^0.5;
        % avoid divide by zero later
        s1Norm{iFilterSize} = s1Norm{iFilterSize}+~s1Norm{iFilterSize};
    end

    % (2) apply filters
    iUFilterIndex = 0;
    for iBand = 1:nBands
        for iScale = 1:length(scalesInThisBand{iBand})
            for iFilt = 1:nFilters
                iUFilterIndex = iUFilterIndex+1;
                if USECONV2 % not 100% compatible but 20% faster at least
                    s1{iBand}{iScale}{iFilt} = abs(conv2(img,sqfilter{iUFilterIndex},'same'));
                else
                    s1{iBand}{iScale}{iFilt} = abs(imfilter(img,sqfilter{iUFilterIndex},'symmetric','same','corr'));
                end
                if(~INCLUDEBORDERS)
                    s1{iBand}{iScale}{iFilt} = removeborders(s1{iBand}{iScale}{iFilt},filterSizes(iUFilterIndex));
                end
                s1{iBand}{iScale}{iFilt} = im2double(s1{iBand}{iScale}{iFilt}) ./ s1Norm{filterSizes(iUFilterIndex)};
            end
        end
    end

    % Calculate local pooling (c1) %

    % (1) pool over scales within band
    for iBand = 1:nBands
        for iFilt = 1:nFilters
            c1PreFilter{iBand}(:,:,iFilt) = zeros(size(s1{iBand}{1}{iFilt}));
            for iScale = 1:length(scalesInThisBand{iBand});
                c1PreFilter{iBand}(:,:,iFilt) = max(c1PreFilter{iBand}(:,:,iFilt),s1{iBand}{iScale}{iFilt});
            end
        end
    end

    % (2) pool over local neighborhood
    for iBand = 1:nBands
        poolRange = (c1Space(iBand));
        for iFilt = 1:nFilters
            c1{iBand}(:,:,iFilt)  = maxFilter(c1PreFilter{iBand}(:,:,iFilt),poolRange);
        end
    end
end

function imgOut = removeborders(imgIn,siz)
    imgMid1 = unpadImage(imgIn, [(siz+1)/2,(siz+1)/2,(siz-1)/2,(siz-1)/2]);
    imgMid2 = padarray(imgMid1, [(siz+1)/2,(siz+1)/2],0,'pre');
    imgOut = padarray(imgMid2, [(siz-1)/2,(siz-1)/2],0,'post');
end
