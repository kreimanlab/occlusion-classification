function alexNetAttractors()
addpath('../data');

netParams=load('./ressources/alexnetParams.mat');
imagesMeanData = load('./ressources/ilsvrc_2012_mean.mat');
imagesMean = imagesMeanData.mean_data;

%% train
[trainImages, trainLabels] = getWholeImages([5:6 65:66]);
p5Outputs = cell(1, length(trainImages));
for i = 1:length(trainImages)
    output = getOutput(trainImages{i}, netParams, imagesMean);
    p5Outputs{i} = output';
end
p5OutputsFlat = cell2mat(p5Outputs);
% attractor network
T = p5OutputsFlat;
T(T > 0) = 1;
T(T == 0) = -1;
net = newhop(T);
% classifier
classifier = fitcecoc(T', trainLabels);

%% test
[testImages, testLabels] = getWholeImages([6:7 66:67]);
for i = 1:length(testImages)
    p5Output = getOutput(testImages{i}, netParams, imagesMean);
    y = net({1 10},{},{p5Output(:)});
    prediction = classifier.predict(y{10}');
    if testLabels(i) == prediction
        disp 'OK'
    else
        disp 'ERR'
    end
end
end

function output = getOutput(image, netParams, imagesMean)
img = prepareGrayscaleImage(image, imagesMean);
p5Output = getPool5Output(netParams, img);
output = interp1(1:length(p5Output), p5Output, 1:1000); % downsample
end
