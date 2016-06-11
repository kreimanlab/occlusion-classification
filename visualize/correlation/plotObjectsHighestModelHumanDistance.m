function plotObjectsHighestModelHumanDistance(corrData, topN)
%PLOTOBJECTSHIGHESTMODELHUMANDISTANCE plots the object with the highest
%distance from the model (positive and negative separate)
if ~exist('topN', 'var')
    topN = 5;
end
images = load('data/KLAB325.mat');
images = images.img_mat;
indicatorColors = ['r', 'g'];
figure('Name', 'Highest distance model - human');
for modelType = 1:numel(corrData.modelNames)
    lastTimestep = find(~any(isnan(corrData.modelCorrect(:, modelType, :))), 1, 'last');
    diffsHumanModel = ...
        corrData.humanCorrect - corrData.modelCorrect(:, modelType, lastTimestep);
    diffsModelHuman = ...
        corrData.modelCorrect(:, modelType, lastTimestep) - corrData.humanCorrect;
    [~, topWorst] = sort(diffsHumanModel, 'descend');
    [~, topBest] = sort(diffsModelHuman, 'descend');
    topPres = [topWorst(1:topN); topBest(1:topN)];
    for topIndex = 1:numel(topPres)
        pres = topPres(topIndex);
        subplot(2 * numel(corrData.modelNames), topN, ...
            2 * (modelType - 1) * topN + topIndex);
        imshow(images{pres});
        modelAccuracy = 100 * mean(corrData.modelCorrect(pres, modelType, lastTimestep));
        humanAccuracy = 100 * mean(corrData.humanCorrect(pres));
        rectangle('position', [1 1 255 255], 'LineWidth', 2, ...
            'edgecolor', indicatorColors(1 + (modelAccuracy > humanAccuracy)));
        title(sprintf('#%d %s %.0f%% - human %.0f%%', ...
            pres, corrData.modelNames{modelType}, ...
            modelAccuracy, humanAccuracy));
    end
end

end

