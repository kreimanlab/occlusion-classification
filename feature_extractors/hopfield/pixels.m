function pixels()
addpath('data');

downsamplingFactor = 5;

%% setup
wholeImages = getWholeImages([5:10 65:70]);

%% train
networkInput = cell(1, length(wholeImages));
for i = 1:length(wholeImages)
    networkInput{i} = prepareImage(wholeImages{i}, downsamplingFactor);
end
net = newhop(cell2mat(networkInput));

%% test
selectedImages = [7:12 67:72];
percentVisible = 20;
testImages = getWholeImages(selectedImages);
occlusionDataProvider = OcclusionDataProvider(testImages, selectedImages);
figure();
for i = 1:length(testImages)
    occludedImage = occlude(testImages(i), percentVisible, ...
        occlusionDataProvider.get(testImages(i)));
    occludedImage = prepareImage(occludedImage{:}, downsamplingFactor);
    prediction = net({1 10},{},{occludedImage});
    % display
    subplot(2, length(testImages), i);
    displayHopfieldImage(occludedImage);
    subplot(2, length(testImages), length(testImages) + i);
    displayHopfieldImage(prediction{10});
end
end

function preparedImage = prepareImage(image, downsamplingFactor)
image = double(image);
image(image~=128) = 1;
image(image==128) = -1;
imageSmall = image(1:downsamplingFactor:end, 1:downsamplingFactor:end, :);
preparedImage = reshape(imageSmall, [numel(imageSmall), 1]);
end

function displayHopfieldImage(image)
l = image;
l(l==-1) = 0;
imshow(reshape(logical(l), [sqrt(numel(l)), sqrt(numel(l))]));
end
