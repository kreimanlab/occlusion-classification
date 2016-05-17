
addpath('./data');
addpath('./pixel');
addpath('./hmax');
addpath('./alexnet');
addpath('./hopfield');
addpath('./visualize');
addpath(genpath('./helper'));

% data
dataset = load('data/data_occlusion_klab325v2.mat');
dataset = dataset.data;
dataset.occluded = []; % delete unneeded columns to free up space
dataset.scramble = []; dataset.pres_time = []; dataset.reaction_times = [];
dataset.responses = []; dataset.correct = []; dataset.VBLsoa = [];
dataset.masked = []; dataset.subject = []; dataset.strong = [];
% selection
[~, uniquePresRows] = unique(dataset, 'pres');
rng(1, 'twister'); % seed for reproducibility
occludedRows = 1:100;%randsample(length(dataset), 100);
occludedRows = unique([occludedRows'; uniquePresRows]');
% classifiers
featureProvidingConstructor = curry(@FeatureProvidingClassifier, ...
    dataset, occludedRows);
hopConstructor = curry(@HopClassifier, 1000);
classifiers = {...
    ...% pixels
    ImageProvidingClassifier(dataset, PixelClassifier()), ...
    featureProvidingConstructor(hopConstructor(ImageProvidingClassifier(dataset, PixelClassifier()))); ...
    ...% hmax
    featureProvidingConstructor(HmaxClassifier()), ...
    featureProvidingConstructor(hopConstructor(HmaxClassifier())); ...
    ...% alexnet pool5
    featureProvidingConstructor(AlexnetPool5ClassifierKlabData()), ...
    featureProvidingConstructor(hopConstructor(AlexnetPool5ClassifierKlabData())); ...
    ...% alexnet fc7
    featureProvidingConstructor(AlexnetFc7ClassifierKlabData()), ...
    featureProvidingConstructor(hopConstructor(0, AlexnetFc7ClassifierKlabData()))...
    };

colors = ['r', 'g', 'b', 'y', 'm'];
numDim = 2;
numRows = nchoosek(numDim, 2);
for classifierIter = 1:length(classifiers)
    classifierName = classifiers{classifierIter, 1}.getName();
    fprintf('%s (%d/%d)\n', ...
        classifierName, classifierIter, length(classifiers));
    figure('Name', classifierName);
    % rotate to properly display on pdf
    orient landscape;
    set(gcf, 'papersize', [17 8.5]);
    set(gcf, 'paperposition', [.25 .25 16.5 8]);
    % show without and with hop
    for hopIter = 1:2
        classifier = classifiers{classifierIter, hopIter};
        wholeFeatures = classifier.extractFeatures(uniquePresRows, RunType.Train);
        wholeLabels = dataset.truth(uniquePresRows);
        occludedFeatures = classifier.extractFeatures(occludedRows, RunType.Test);
        occludedLabels = dataset.truth(occludedRows);
        mappedX = tsne([wholeFeatures', occludedFeatures']', [], numDim);
        mappedXWhole = mappedX(1:size(wholeFeatures, 1), :);
        mappedXOccluded = mappedX(size(wholeFeatures, 1) + 1:end, :);
        % plot x,y[;y,z;z,x etc]
        for dimX = 1:numRows
            ax = subplot(numRows, 2, hopIter + (dimX - 1) * 2);
            set(gca, 'XTickLabel', ''); set(gca, 'YTickLabel', '');
            hold(ax, 'on');
            dimY = mod(dimX, numDim) + 1;
            gscatter(mappedXWhole(:,dimX), mappedXWhole(:,dimY), ...
                stringifyLabels(wholeLabels), colors, 'o', [], false);
            gscatter(mappedXOccluded(:,dimX), mappedXOccluded(:,dimY), ...
                stringifyLabels(occludedLabels), colors, '.', [], false);
            hold off;
        end
    end
    savefig(['data/visualize/' classifierName]);
end
