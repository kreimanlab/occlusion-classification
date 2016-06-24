function directory = getFeaturesDirectory()
%GETFEATURESDIRECTORY Get the directory the features are stored in.

directory = [fileparts(mfilename('fullpath')), '/../../data/features/'];
% use central cluster directory if possible
orchestraDir = '/groups/kreiman/martin/features/';
if exist(orchestraDir, 'dir')
    directory = orchestraDir;
end
end
