function [trainDir, testDir, directory] = getFeaturesDirectories()
%GETFEATURESDIRECTORY Get the train, test and parent directories the 
%features are stored in.
directory = [fileparts(mfilename('fullpath')), '/'];
% use central cluster directory if possible
orchestraDir = '/groups/kreiman/martin/features/';
if exist(orchestraDir, 'dir')
    directory = orchestraDir;
end
trainDir = [directory, 'klab325_orig/'];
testDir = [directory, 'data_occlusion_klab325v2/'];
end
