function imgOut = unpadImage(imgIn,pad)
% imgOut = unpadImage(imgIn,pad)
%
% undoes padimage
% given an image and padding amount, this function strips padding off an image
%
% args:
%
%     imgIn: a 2- or 3-dimensional matrix, the image to be unpadded
%
%     pad: a scalar or matrix, indicates how many pixels to strip from each side
%     if length(pad) == 1, unpad equally on all sides
%     if length(pad) == 2, first is left & right, second up & down
%     if length(pad) == 4, [left top right bottom];
%
% returns:
%
%     imgOut: a 2- or 3-dimensional matrix, the unpadded image
%
% see also padImage.m

    switch length(pad)
    case 1
        l = pad + 1;
        r = size(imgIn,2) - pad;
        t = pad + 1;
        b = size(imgIn,1) - pad;
    case 2
        l = pad(1) + 1;
        r = size(imgIn,2) - pad(1);
        t = pad(2) + 1;
        b = size(imgIn,1) - pad(2);
    case 4
        l = pad(1) + 1;
        r = size(imgIn,2) - pad(3);
        t = pad(2) + 1;
        b = size(imgIn,1) - pad(4);
    otherwise
        fprintf('unpadImage: illegal unpad amount, returning []\n');
        imgOut = [];
        return;
    end
    if(any([b-t,r-l] < 1))
        fprintf('unpadImage: new size < 0, returning []\n');
        imgOut = [];
        return;
    end
    imgOut = imgIn(t:b,l:r,:);
end
