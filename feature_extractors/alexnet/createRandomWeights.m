function randomWeights = createRandomWeights(originalWeights)
dir = fileparts(mfilename('fullpath'));
if ~exist('originalWeights', 'var')
    originalWeights = load([dir '/ressources/alexnetParams.mat']);
end

randomWeights = originalWeights.weights;
rng(0, 'twister');
for i = 1:8
    fprintf('Layer %d\n', i);
    kernels = originalWeights.weights(i).weights{1};
    biases = originalWeights.weights(i).weights{2};
    if i <= 5 % convolution
         randomKernels = sampleOver4Depth(kernels);
    else % fully connected
         randomKernels = sampleOverAll(kernels);
    end
    randomWeights(i).weights{1} = randomKernels;
    randomWeights(i).weights{2} = sampleOverAll(biases);
end
weights = randomWeights;
save([dir '/ressources/randomParams.mat'], 'weights');
end

function randomWeights = sampleOver4Depth(originalKernels)
s = size(originalKernels);
randomWeights = NaN(s);
for depthSlice = 1:size(originalKernels, 4)
    vals = originalKernels(:, :, :, depthSlice);
    model = fitdist(vals(:), 'normal');
    assert(model.mu < 0.01);
    randomWeights(:, :, :, depthSlice) = random(model, s(1:end-1));
end
end

function randomWeights = sampleOverAll(originalValues)
s = size(originalValues);
model = fitdist(originalValues(:), 'normal');
randomWeights = random(model, s);
end
