function downsampled = downsampleNth(x, downsampledLength)
sampleSteps = ceil(size(x, 2) / downsampledLength);
downsampled = zeros(size(x, 1), ceil(size(x, 2) / sampleSteps));
for i = 1:size(x, 1)
    downsampled(i, :) = downsample(x(i, :), sampleSteps);
end
end
