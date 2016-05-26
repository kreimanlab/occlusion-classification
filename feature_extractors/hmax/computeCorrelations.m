function computeCorrelations(mode)
if nargin < 1
    mode = 'diff';
end

dir = fileparts(mfilename('fullpath'));
addpath([dir '/../data']);
featuresDir = [dir '/../data/OcclusionModeling/features'];

if strcmp(mode, 'diff')
    compareFnc = @(whole, occluded) whole - occluded; % diff
elseif strcmp(mode, 'occ')
    compareFnc = @(whole, occluded) occluded; % show only occluded
elseif strcmp(mode, 'whole')
    compareFnc = @(whole, occluded) whole; % show only whole
else
    error('Invalid mode %s', mode);
end

global wholeFeatures
global occludedFeatures
if ~exist('wholeFeatures', 'var')
    wholeFeatures = load([featuresDir '/klab325_orig/'...
        'hmax_all_1- 66-131-196-261.mat']);
    wholeFeatures = wholeFeatures.features(1);
end

if ~exist('occludedFeatures', 'var')
    occludedFeatures = load([featuresDir '/data_occlusion_klab325v2/'...
        'hmax_all_1.mat']);
    occludedFeatures = occludedFeatures.features(5);
end

%showImages(wholeFeatures.pres, occludedFeatures.row);
%showS1(wholeFeatures.s1{1}, occludedFeatures.s1{1}, compareFnc, mode);
%showC1(wholeFeatures.c1{1}, occludedFeatures.c1{1}, compareFnc, mode);
%showS2(wholeFeatures.s2{1}, occludedFeatures.s2{1}, compareFnc, mode);
%showC2(wholeFeatures.c2, occludedFeatures.c2, compareFnc, mode);

occlusionData = load('data/data_occlusion_klab325v2.mat');
occlusionData = occlusionData.data;
for i=1:5
    % TODO: pick two patch sizes, plot all occlusions in one figure
    row = occludedFeatures(i).row;
    occlusion = occlusionData.black(row);
    occludedC2 = occludedFeatures(i).c2;
    plotAgainstC2(wholeFeatures.c2, occludedC2, ...
        sprintf('(%.2f%% occlusion)', occlusion));
end
end

function showS1(wholeS1, occludedS1, compareFnc, modeName)
figure('Name', ['S1 ' modeName]);
% s1{8 x iBand}{2 x iScale}{4 x iFilt}
for band = 1:8
    for scale = 1:2
        for filt = 1:4
            vals = compareFnc(wholeS1{band}{scale}{filt}, ...
                occludedS1{band}{scale}{filt});
            subplot(8, 8, 8 * (band - 1) + 4 * (scale - 1) + filt);
            imagesc(vals);
            set(gca, 'XTickLabel', ''); set(gca, 'YTickLabel', '');
            title(sprintf('band %d, scale %d, filt %d', band, scale, filt));
        end
    end
end
lastSubplot = get(subplot(8, 8, 64), 'Position');
colorbar('Position', [lastSubplot(1)+lastSubplot(3)+0.03, lastSubplot(2), ...
    0.01, lastSubplot(2)+lastSubplot(3)*9.3]);
end

function showC1(wholeC1, occludedC1, compareFnc, modeName)
figure('Name', ['C1 ' modeName]);
% c1{iBand}(:,:,iFilt) = maxFilter
for band = 1:8
    for filt = 1:4
        vals = compareFnc(wholeC1{band}(:,:,filt), occludedC1{band}(:,:,filt));
        subplot(8, 4, 4 * (band - 1) + filt);
        imagesc(vals);
        title(sprintf('band %d, filt %d', band, filt));
    end
end
lastSubplot = get(subplot(8, 4, 32), 'Position');
colorbar('Position', [lastSubplot(1)+lastSubplot(3)+0.03, lastSubplot(2), ...
    0.01, lastSubplot(2)+lastSubplot(3)*4.6]);
end

function showS2(wholeS2, occludedS2, compareFnc, modeName)
% s2{iPatchSize}{iPatch}{iBand} = windowedPatchDistance
numBands = 1;% 8 total, use only the first one
for band = 1:numBands
    figure('Name', sprintf('S2 %s band %d', modeName, band));
    numPatchSizes = 8;
    for patchSize = 1:numPatchSizes
        patches = 40:40:400;
        for patch = patches
            vals = compareFnc(wholeS2{patchSize}{patch}{band}, ...
                occludedS2{patchSize}{patch}{band});
            subplot(numPatchSizes, length(patches), ...
                length(patches) * (patchSize - 1) + patch/40);
            imagesc(vals);
            title(sprintf('patchSize %d, patch %d', ...
                patchSize, patch));
        end
    end
    firstSubplot = get(subplot(numPatchSizes, length(patches), ...
        1), 'Position');
    lastSubplot = get(subplot(numPatchSizes, length(patches), ...
        numPatchSizes*length(patches)), 'Position');
    colorbar('Position', [lastSubplot(1)+lastSubplot(3)+0.03, lastSubplot(2), ...
        0.01, firstSubplot(2) + firstSubplot(4) - lastSubplot(2)]);
end
end

function showC2(wholeC2, occludedC2, compareFnc, modeName)
figure('Name', ['C2 ' modeName]);
% c2{iPatchSize}(patchIndices,iImg)
for patchSize = 1:8
    vals = compareFnc(wholeC2{patchSize}', occludedC2{patchSize}');
    subplot(8, 1, patchSize);
    imagesc(vals);
    title(sprintf('patchSize %d', patchSize));
    set(gca, 'YTickLabel', '');
    if patchSize == 8
        xlabel('patch indices');
    else
        set(gca, 'XTickLabel', '');
    end
end
lastSubplot = get(subplot(8, 1, 8), 'Position');
colorbar('Position', [lastSubplot(1)+lastSubplot(3)+0.03, lastSubplot(2), ...
    0.01, lastSubplot(2)+lastSubplot(3)*0.95]);
end

function plotAgainstC2(wholeC2, occludedC2, titleDetails)
figure('Name', ['C2 ' titleDetails]);
% c2{iPatchSize}(patchIndices,iImg)
numPatchSizes = 8;
for patchSize = 1:numPatchSizes
    subplot(numPatchSizes / 2, 2, patchSize);
    [pm, ax] = plotmatrix(wholeC2{patchSize}, occludedC2{patchSize});
    set(pm, 'MarkerFaceColor', get(pm, 'Color'));
    set(pm, 'MarkerSize', 10);
    hold(ax, 'on');
    plot(ax, wholeC2{patchSize}, wholeC2{patchSize});
    xlim(ax, [min(wholeC2{patchSize}), max(wholeC2{patchSize})]);
    ylim(ax, [min(wholeC2{patchSize}), max(wholeC2{patchSize})]);
    title(sprintf('patchSize %d', patchSize));
    hold off;
end
end


function showImages(pres, occlusionRow)
figure('Name', 'Images');
dir = fileparts(mfilename('fullpath'));

images = load([dir '/../data/KLAB325.mat']);
images = images.img_mat;
subplot(1, 2, 1);
imshow(images{pres});
title('whole');

occlusionData = load([dir '/../data/data_occlusion_klab325v2.mat']);
occlusionData = occlusionData.data(occlusionRow, :);
occludedImage = occlude(images(pres), 1, occlusionData);
subplot(1, 2, 2);
imshow(occludedImage{1});
title(sprintf('%.2f%% occlusion', occlusionData.black));
end




function s1P = simplifyS1(s1)
s1P = horzcat(s1{:});
s1P = vertcat(s1P{:});
s1P = cellfun(@cell2mat, s1P, 'UniformOutput', false);
s1P = cell2mat(s1P);
s1P = reshape(s1P, [1 numel(s1P)]);
end
