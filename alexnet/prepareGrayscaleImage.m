%Return an image that serves as input to AlexNet.
%imageData is the KLAB grayscale image data
%preprocessed_image is a 3d matrix with dimensions 227x227x3.
%preprocessed_image is WxHxC major in BGR.
function [preprocessedImage] = prepareGrayscaleImage(imageData, imagesMean)
    IMAGE_DIM = 256;
    CROPPED_DIM = 227;
    % Convert an image returned by Matlab's imread to im_data in caffe's data
    % format: W x H x C with BGR channelsM = 227;
    rgbImage = repmat(imageData, [1 1 3]);
    imageData = rgbImage(:, :, [3, 2, 1]);  % permute channels from RGB to BGR
    imageData = permute(imageData, [2, 1, 3]);  % flip width and height
    imageData = single(imageData);  % convert from uint8 to single
    imageData = imresize(imageData, [IMAGE_DIM IMAGE_DIM], 'bilinear');  % resize im_data
    imageData = imageData - imagesMean;  % subtract mean_data (already in W x H x C, BGR)
    imageData = imresize(imageData, [CROPPED_DIM CROPPED_DIM], 'bilinear');  % resize im_data
    preprocessedImage = zeros(CROPPED_DIM, CROPPED_DIM, 3, 'double');
    preprocessedImage(:,:,:)=imageData;
end

