function imgOut = sumFilter(imgIn,radius)
% imgOut = sumFilter(imgIn,radius);
%
% Given an image and pooling range, returns an image where each "pixel"
% represents the sums of the pixel values within the pooling range of the
% original pixel.
%
% args:
%
%     imgIn: a 2-dimensional matrix, the image to be filtered
%
%     radius: a scalar or vector, the additional radius of the filter pool,
%     For a scalar, ex. radius = 5 means a filter pool of 11 x 11
%     For a vector, use the order [left top right bottom].
%
% returns:
%
%     imgOut: a matrix the size of imgIn, where each pixel, imgOut(x,y),
%     represents the sum of the values of all pixels in imgIn within the
%     neighborhood of imgIn(x,y) defined by radius

    assert((size(imgIn,3) == 1), 'Only single-channel images are allowed');

    switch length(radius)
    case 4,
        imgOut = conv2(imgIn, ones(radius(2)+radius(4)+1,radius(1)+radius(3)+1), 'same');
    case 1,
        imgOut = conv2(imgIn, ones(2*radius+1), 'same');
    end
end
