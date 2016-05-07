function [c2,c1,bestBands,bestLocations,s2,s1] = ...
    runHmax(images)

%% Preprocess the images.
% Creates a cell array with each cell containing a grayscaled
% representation of one image. Data type should be double, not uint8.
for iImg = 1:size(images,2)
    images{iImg} = double(images{iImg});
end

%% Initialize S1 gabor filters and C1 parameters
fprintf('initializing S1 gabor filters\n');
orientations = [90 -45 0 45]; % 4 orientations for gabor filters
RFsizes      = 7:2:39;        % receptive field sizes
div          = 4:-.05:3.2;    % tuning parameters for the filters' "tightness"
[filterSizes,filters,c1OL,~] = initGabor(orientations,RFsizes,div);

fprintf('initializing C1 parameters\n');
c1Scale = 1:2:18; % defining 8 scale bands
c1Space = 8:2:22; % defining spatial pooling range for each scale band

%% Load the universal patch set.
fprintf('Loading the universal patch set\n');
load('universal_patch_set.mat','patches','patchSizes');

nPatchSizes = size(patchSizes,2);


%% For each patch calculate responses
fprintf('calculating unit responses\n');

[c2,c1,bestBands,bestLocations,s2,s1] = extractC2forCell...
    (filters,filterSizes,c1Space,c1Scale,c1OL,patches,images,nPatchSizes,patchSizes(1:3,:));
