function[fc7] = getImageFc7Outputs(images)
fc7=zeros(length(images),FC7OUTPUT_LENGTH);
for img=1:length(images)
    data = prepareGrayscaleImage(images{img});
    % extract features
    fc7Single=getFc7Output(netParams, data);
    fc7(img,:) = fc7Single(:);
end