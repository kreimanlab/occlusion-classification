function paths = lsDir(directory, extensions)
% paths = lsDir(directory, extensions)
%
% gives a cell array of path for images in the given directory
%
% directory: a string, the name of the directory to search
% extensions: string cell array, extensions to include
%     in the list. Use {'*'} for all files.
%
% paths: string cell array, all files matching 'directory/*.exts'
imgsByExt = cellfun(@(x) dir(fullfile(directory, ['*.' x])),...
                             extensions,...
                             'UniformOutput',0);
imgList = [];
for iExt = 1:length(imgsByExt)
    imgList = [imgList imgsByExt{iExt}'];
end
paths = arrayfun(@(x) fullfile(directory,x.name),...
                               imgList,...
                               'UniformOutput',0);
paths = cellstr(paths);
end
