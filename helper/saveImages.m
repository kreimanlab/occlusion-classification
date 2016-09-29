function saveImages(dir, images)
%SAVEIMAGES saves the given images in the given directory
if ~exist(dir, 'dir')
    mkdir(dir);
end
for i = 1:numel(images)
    image = images{i};
    imwrite(image, [dir '/' num2str(i) '.jpg']);
end
