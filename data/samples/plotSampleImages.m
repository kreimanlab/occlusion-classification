function plotSampleImages()
images = load('data/KLAB325.mat');
images = images.img_mat;
occlusionData = load('data/data_occlusion_klab325v2.mat');
occlusionData = occlusionData.data;
lessOcclusionData = load('data/lessOcclusion/data_occlusion_klab325-high_visibility.mat');
lessOcclusionData = lessOcclusionData.data;
bubbleSigmas = repmat(14, [size(occlusionData, 1), 10]);

categories = {
    'animal', [1:60, 301:305]; ...
    'chair', [61:120, 306:310]; ...
    'face', [121:180, 311:315]; ...
    'fruit', [181:240, 316:320]; ...
    'vehicle', [241:300, 321:325]
    };

rng(0);
sampleImages = cellfun(@(indices) randsample(indices, 1), ...
    categories(:, 2), 'UniformOutput', false);
occlusionData = cellfun(@(indices) occlusionData(randsample(find(ismember(occlusionData.pres, indices)), 3), :), ...
    sampleImages, 'UniformOutput', false);
lessOcclusionData = cellfun(@(indices) lessOcclusionData(randsample(find(ismember(lessOcclusionData.pres, indices)), 3), :), ...
    sampleImages, 'UniformOutput', false);

numColumns = 8;
numRows = 8;
setappdata(gcf, 'SubplotDefaultAxesLocation', [0, 0, 1, 1]);
fig = figure('Position', [0, 0, 512, 512]);
for c = 1:size(categories, 1)
    %% whole
    col = 1;
    subplot('Position', subplotPos(c, col, numRows, numColumns));
    image = images{sampleImages{c}};
    imshow(image);
    annotation('line', [1, 1], [0, 1]);
    if c == 1
        title('whole');
    end
    %% occluded
    occluded = occlusionData{c};
    assert(unique(occluded.truth) == c);
    for row = 1:size(occluded, 1)
        col = 1 + row;
        subplot('Position', subplotPos(c, col, numRows, numColumns));
        occludedImage = occlude({image}, occluded.nbubbles(row), ...
            occluded.bubble_centers(row, :), bubbleSigmas(row, :));
        occludedImage = occludedImage{1};
        imshow(occludedImage);
        if c == 1 && row == 1
            title('high occlusion (focus of this work)');
        end
    end
    %% less-occluded
    lessOccluded = lessOcclusionData{c};
    assert(unique(lessOccluded.truth) == c);
    for row = 1:size(lessOccluded, 1)
        col = 1 + size(occluded, 1) + row;
        subplot('Position', subplotPos(c, col, numRows, numColumns));
        lessOccludedImage = occlude({image}, lessOccluded.nbubbles(row), ...
            lessOccluded.bubble_centers(row, :), ...
            lessOccluded.bubbleSigmas(row, :));
        lessOccludedImage = lessOccludedImage{1};
        imshow(lessOccludedImage);
        if c == 1 && row == 1
            title('low occlusion');
        end
    end
    %% label
    category = categories{c, 1};
    col = 1 + size(occluded, 1) + size(lessOccluded, 1) + 1;
    subplot('Position', subplotPos(c, col, numRows, numColumns));
    text(0.3, 0.5, category);
    clearPlot();
end
saveas(fig, 'sample_images.svg');
end

function clearPlot()
grid('off');
set(gca,'xtick',[],'ytick',[]);
end

function pos = subplotPos(row, col, numRows, numColumns)
verticalSpacing = 0.01;
horizontalSpacing = 0.01;
pos = [(col - 1) / numColumns, 1 - row / numRows, ...
    1 / numRows - verticalSpacing, 1 / numColumns - horizontalSpacing];
end
