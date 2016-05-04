function imgOut = padImage(imgIn,pad,method)
% imgOut = padImage(imgIn,pad,method)
% 
% Given an image, padding amount, and padding method, returns a padded image.
% Think of it as padarray operating on only the first 2 dimensions of a 3
% dimensional image.
%
% args:
%
%     imgIn: 2- or 3-dimensional matrix, the image to be padded
%
%     pad: scalar, indicates how many pixels pad each side
%
%     method: string or scalar, indicates the padding method. Possible values:
%        'circular'    Pad with circular repetion of elements.
%        'replicate'   Repeat border elements of A.
%        'symmetric'   Pad array with mirror reflections of itself. 
%        XYZ           scalars, ex. 0, 14, 255
%
% returns:
%
%     imgOut: a 2- or 3-dimensional matrix, the unpadded image
%
% see also unpadImage.m

    if (nargin < 3) method = 'replicate'; end;

    imgOut = zeros(size(imgIn,1)+2*pad, size(imgIn,2)+2*pad, size(imgIn,3));
    for iLayer = 1:size(imgIn,3)
        imgOut(:,:,iLayer) = padarray(imgIn(:,:,iLayer),[pad,pad],method,'both');
    end
end
