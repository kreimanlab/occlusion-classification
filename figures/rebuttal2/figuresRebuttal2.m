function figuresRebuttal2()
%% collect data
% Alexnet finetrain 1:1
alexnetFinetrainRelu7_1_1Results = loadData('data/results/classification/alexnet-finetune-relu7-1_1.mat', 'results');
alexnetFinetrainRelu7_1_1AllVisibilitiesResults = loadData('data/results/classification/alexnet-finetune-relu7-1_1-all.mat', 'results');

figures = NaN(0);
%% performances
figures(end + 1) = figure('Name', 'R2-performance_vs_visibility-alexnet-finetune-relu7-1_1-Jan18');
displayResults(alexnetFinetrainRelu7_1_1Results);
figures(end + 1) = figure('Name', 'R2-performance_vs_visibility-alexnet-finetune-relu7-1_1-all');
displayResults(alexnetFinetrainRelu7_1_1AllVisibilitiesResults, false, [0, 0.1, 5:5:95, 99], [], false);

%% correlations per category
corrData = collectModelHumanCorrelationData(...
    joinExperimentData(alexnetFinetrainRelu7_1_1Results, loadData('data/data_occlusion_klab325v2.mat', 'data')));
figures(end + 1) = figure('Name', 'R2_4E-correlation_vs_time-per_category');
plotCategoryCorrelationOverTime(corrData);

%% save figures
scriptDir = fileparts(mfilename('fullpath'));
for fig = figures
    figName = get(fig, 'Name');
    figName = strrep(figName, '/', '_');
    saveFile = [scriptDir, '/', figName];
    saveas(fig, saveFile);
    export_fig(saveFile, '-eps', fig);
    close(fig);
end
end
