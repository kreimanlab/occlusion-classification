function plotWholeVsOccludedTsne()

% data
dataset = load('data/data_occlusion_klab325v2.mat');
dataset = dataset.data;
dataSelection = 1:13000;
% selection
[~, rows] = unique(dataset.pres(:)); % pick one version of each object
rows = rows';
% feature extractors
featureProviderFactory = FeatureProviderFactory(dataset, dataSelection);
featureExtractors = {...
    featureProviderFactory.get(AlexnetFc7Features()), ...
    featureProviderFactory.get(HopFeatures(20, BipolarFeatures(0, AlexnetFc7Features()))), ...
    featureProviderFactory.get(HopFeatures(300, BipolarFeatures(0, AlexnetFc7Features()))); ...
        featureProviderFactory.get(AlexnetFc7Features()), ...
        RnnFeatureProvider(dataset, RnnFeatures(4, [])); ...
    };

[labelNames, colors] = getCategoryLabels();
colors = cell2mat(colors);
numDim = 2;
numRows = nchoosek(numDim, 2);
for featIter = 1:size(featureExtractors, 1)
    extractorName = featureExtractors{featIter, end}.getName();
    numSteps = size(featureExtractors, 2);
    fprintf('%s (%d/%d)\n', ...
        extractorName, featIter, numSteps);
    figure('Name', extractorName);
    % show over time
    for timestep = 1:numSteps
        extractor = featureExtractors{featIter, timestep};
        wholeFeatures = extractor.extractFeatures(rows, RunType.Train);
        occludedFeatures = extractor.extractFeatures(rows, RunType.Test);
        labels = dataset.truth(rows);
        mappedX = tsne([wholeFeatures', occludedFeatures']', [], numDim);
        mappedXWhole = mappedX(1:size(wholeFeatures, 1), :);
        mappedXOccluded = mappedX(size(wholeFeatures, 1) + 1:end, :);
        % plot x,y[;y,z;z,x]
        for dimX = 1:numRows
            ax = subplot(numRows, numSteps, timestep + (dimX - 1) * 2);
            set(gca, 'XTickLabel', ''); set(gca, 'YTickLabel', '');
            hold(ax, 'on');
            dimY = mod(dimX, numDim) + 1;
            categoryLabels = getCategoryLabels(labels);
            gscatter(mappedXWhole(:,dimX), mappedXWhole(:,dimY), ...
                categoryLabels, colors, 'o', [], false);
            gscatter(mappedXOccluded(:,dimX), mappedXOccluded(:,dimY), ...
                categoryLabels, colors, '.', [], false);
            if (timestep == 1)
                legend(labelNames);
            end
            hold off;
        end
    end
    savefig(['figures/tsne/' extractorName]);
end
