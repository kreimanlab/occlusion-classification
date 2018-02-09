function figuresRebuttal2()
subplot = @(m,n,p) subtightplot(m,n,p);

%% collect data
% Alexnet finetrain 1:1
alexnetFinetrainRelu7_1_1ResultsJan18 = loadData('data/results/classification/alexnet-finetune-relu7-1_1.mat', 'results');
alexnetFinetrainRelu7_1_1ResultsAcrossObjects = loadData('data/results/classification/alexnet-finetune-relu7-across_objects-1_1-corrected.mat', 'results');
alexnetFinetrainRelu7_1_1ResultsAcrossCategories = loadData('data/results/classification/alexnet-finetune-relu7-across_categories-1_1.mat', 'results');
alexnetFinetrainRelu7_1_1ResultsAcrossVisibilities = loadData('data/results/classification/alexnet-finetune-relu7-1_1-across_visibilities.mat', 'results');

figures = NaN(0);
%% performances
figures(end + 1) = figure('Name', 'R2-performance_vs_visibility-alexnet-finetune-relu7-across_objects-1_1-Jan18');
displayResults(alexnetFinetrainRelu7_1_1ResultsJan18);
allOcclusionLevels = [0, 0.1, 5:5:95, 99];
figures(end + 1) = figure('Name', 'R2-performance_vs_visibility-alexnet-finetune-relu7-across_objects-1_1');
displayResults(alexnetFinetrainRelu7_1_1ResultsAcrossObjects, false, allOcclusionLevels, [], false);
figures(end + 1) = figure('Name', 'R2-performance_vs_visibility-alexnet-finetune-relu7-across_categories-1_1');
displayResults(alexnetFinetrainRelu7_1_1ResultsAcrossCategories, false, allOcclusionLevels, [], false);

figures(end + 1) = figure('Name', 'R2-performance_vs_visibility-alexnet-finetune-relu7-across_visibilities');
setappdata(gcf, 'SubplotDefaultAxesLocation', [0, 0, 1, 1]);
for i = 0:9
    subplot(2, 5, i + 1);
    visibilityLevels = [num2str(i * 10), '_', num2str((i + 1) * 10)];
    results = filterResults(alexnetFinetrainRelu7_1_1ResultsAcrossVisibilities, ...
        @(r) strcmp(r.name, ['alexnet-finetune_relu7-1_1-visibility_', visibilityLevels, '-libsvmccv']));
    displayResults(results, false, allOcclusionLevels, [], false);
    title(['train on ', num2str(i * 10), '-', num2str((i + 1) * 10)]);
    if i < 5
        set(gca, 'XTickLabel', [], 'XTick', []);
    end
    if mod(i, 5) ~= 0
        set(gca, 'YTickLabel', [], 'YTick', []);
        ylabel('');
    end
end

%% correlations per category
corrData = collectModelHumanCorrelationData(...
    joinExperimentData(alexnetFinetrainRelu7_1_1ResultsJan18, loadData('data/data_occlusion_klab325v2.mat', 'data')));
figures(end + 1) = figure('Name', 'R2_4E-correlation_vs_time-per_category');
plotCategoryCorrelationOverTime(corrData);
figures(end + 1) = figure('Name', 'R2-6E-correlation_vs_time');
plotCorrelationOverTime(corrData);

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
