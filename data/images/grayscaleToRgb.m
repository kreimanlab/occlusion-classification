function image = grayscaleToRgb(image, format)
image = image(:, :, [1 1 1]); % channels last
if strcmp(format, 'channels-first')
    image = permute(image, [3, 1, 2]); % reorder to channels first
else
    assert(strcmp(format, 'channels-last'));
    % no permutation necessary
end
end
