function [c2,c1,bestBands,bestLocations,s2,s1] = ...
         example(exampleImages,saveFolder)
% [c2,c1,bestBands,bestLocations,s2,s1] = example(exampleImages,saveFolder)
%
% An example code showing how HMAX is initalized and used. This function
% will call all the relevant functions to generate C2 activations for the
% patches and images provided.
%
% args:
%
%     exampleImages: a cell array. Each cell should contain the full 
%                    path to an image.
%    
%     saveFolder: a string. Directory to save the output in.
%
% returns:
%
%     c2,s2,c1,s1: see C1.m and C2.m
%
%     filters: the gabor filters used for computing S1 responses
    

    %% If no arguments are provided, these are the default variables.
    if (nargin < 1) 
        saveFolder = './output/';
        load('exampleImages.mat');
    end
    
    %% Preprocess the images.
    % Creates a cell array with each cell containing a grayscaled
    % representation of one image. Data type should be double, not uint8.
    for iImg = 1:size(exampleImages,2)
            exampleImages{iImg} = double(rgb2gray(imread(exampleImages{iImg})));
    end
        
    %% Initialize S1 gabor filters and C1 parameters
    fprintf('initializing S1 gabor filters\n');
    orientations = [90 -45 0 45]; % 4 orientations for gabor filters
    RFsizes      = 7:2:39;        % receptive field sizes
    div          = 4:-.05:3.2;    % tuning parameters for the filters' "tightness"
    [filterSizes,filters,c1OL,~] = initGabor(orientations,RFsizes,div);
    
    fprintf('initializing C1 parameters\n')
    c1Scale = 1:2:18; % defining 8 scale bands
    c1Space = 8:2:22; % defining spatial pooling range for each scale band
    
    %% Load the universal patch set.
    fprintf('Loading the universal patch set\n')
    load('universal_patch_set.mat','patches','patchSizes');
    
    nPatchSizes = size(patchSizes,2);


    %% For each patch calculate responses
    fprintf('calculating unit responses\n');    
    
    [c2,c1,bestBands,bestLocations,s2,s1] = extractC2forCell...
        (filters,filterSizes,c1Space,c1Scale,c1OL,patches,exampleImages,nPatchSizes,patchSizes(1:3,:));
    
    %% Save the output
    save([saveFolder 'exampleActivations.mat'], '-v7.3', ...
            'c2','bestBands','bestLocations'...
        );
%            ,'c1','s2','s1'...
end
