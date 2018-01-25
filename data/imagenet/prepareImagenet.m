function prepareImagenet(imagesDirectory, targetDirectory, occludedWholeRatio)
%PREPAREIMAGENET prepares the data for fine-tuning (mixed training)
%   occludedWholeRatio: number of occluded images to train on divided by 
%   number of whole images to train on

scriptDirectory = fileparts(mfilename('fullpath'));
assert(exist('imagesDirectory', 'var') == 1);
if ~exist('targetDirectory', 'var')
    targetDirectory = [scriptDirectory, '/processed_images/'];
end
imagesDirectory = char(imagesDirectory); targetDirectory = char(targetDirectory);
mkdir(targetDirectory);
fprintf('running with imagesDirectory=%s, targetDirectory=%s\n', ...
    imagesDirectory, targetDirectory);

%% settings
if ~exist('occludedWholeRatio', 'var')
    occludedWholeRatio = 1/1;
end

%% read images
subDirectories = dir(imagesDirectory);
subDirectories = {subDirectories.name};
subDirectories(ismember(subDirectories, {'.', '..'})) = [];
for dirCounter = 1:numel(subDirectories)
    subDirectory = subDirectories{dirCounter};
    fprintf('Directory %d/%d: %s\n', dirCounter, numel(subDirectories), subDirectory);
    imagesSubDirectory = [imagesDirectory, '/', subDirectory];
    targetSubDirectory = [targetDirectory, '/', subDirectory];    
    prepareImagenetSubdirectory(imagesSubDirectory, targetSubDirectory, occludedWholeRatio);
end
end
