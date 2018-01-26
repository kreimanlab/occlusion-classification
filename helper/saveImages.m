function saveImages(dir, images, filenames)
%SAVEIMAGES saves the given images in the given directory
if ~exist(dir, 'dir')
    mkdir(dir);
end
if ~exist('filenames', 'var')
    filenames = arrayfun(@num2str, 1:numel(images), 'UniformOutput', false);
end
for i = 1:numel(images)
    image = images{i};
    targetPath = [dir '/' filenames{i}];
    if ~ismember(targetPath, '.')
         targetPath = [targetPath, '.jpg'];
    end
    targetDir = fileparts(targetPath);
    if exist(targetDir, 'dir') ~= 7
        mkdir(targetDir);
    end
    imwrite(image, targetPath);
end
