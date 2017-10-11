function writeDataPres(filepath)
if ~exist('filepath', 'var')
    filepath = 'data/data_occlusion_klab325v2.mat';
end
data = load(filepath);
pres = data.data.pres;

[path, basename, ~] = fileparts(filepath);
presFilepath = [path, '/', basename, '-pres.txt'];
fileId = fopen(presFilepath,'w');
fprintf(fileId, '%d\n', pres);
fclose(fileId);
end
