
addpath(genpath(pwd));

% data
dataset = load('data/data_occlusion_klab325v2.mat');
dataset = dataset.data;
% selection
[~, rows] = unique(dataset.pres(:)); % pick one version of each object
rows = rows';
% classifiers
featureProvidingConstructor = curry(@FeatureProvidingClassifier, ...
    dataset, rows);
hopConstructor = curry(@HopClassifier, 1000);
classifiers = {...
    ...% pixels
    ImageProvidingClassifier(dataset, PixelClassifier()), ...
    featureProvidingConstructor(hopConstructor(ImageProvidingClassifier(dataset, PixelClassifier()))); ...
    ...% hmax
    featureProvidingConstructor(HmaxClassifier()), ...
    featureProvidingConstructor(hopConstructor(HmaxClassifier())); ...
    ...% alexnet pool5
    featureProvidingConstructor(AlexnetPool5Classifier()), ...
    featureProvidingConstructor(hopConstructor(AlexnetPool5Classifier())); ...
    ...% alexnet fc7
    featureProvidingConstructor(AlexnetFc7Classifier()), ...
    featureProvidingConstructor(hopConstructor(0, AlexnetFc7Classifier()))...
    };

colors = ['r', 'b', 'g', 'y', 'm'];
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
        wholeFeatures = classifier.extractFeatures(rows, RunType.Train);
        occludedFeatures = classifier.extractFeatures(rows, RunType.Test);
        labels = dataset.truth(rows);
        mappedX = tsne([wholeFeatures', occludedFeatures']', [], numDim);
        mappedXWhole = mappedX(1:size(wholeFeatures, 1), :);
        mappedXOccluded = mappedX(size(wholeFeatures, 1) + 1:end, :);
        % plot x,y[;y,z;z,x]
        for dimX = 1:numRows
            ax = subplot(numRows, 2, hopIter + (dimX - 1) * 2);
            set(gca, 'XTickLabel', ''); set(gca, 'YTickLabel', '');
            hold(ax, 'on');
            dimY = mod(dimX, numDim) + 1;
            gscatter(mappedXWhole(:,dimX), mappedXWhole(:,dimY), ...
                stringifyLabels(labels), colors, 'o', [], false);
            gscatter(mappedXOccluded(:,dimX), mappedXOccluded(:,dimY), ...
                stringifyLabels(labels), colors, '.', [], false);
            hold off;
        end
    end
    savefig(['data/visualize/' classifierName]);
end
