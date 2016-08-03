function categoriesModelsLegend()
[categories, colors] = getCategoryLabels();
[modelNames, ~, modelLines, modelMarkers] = getModelLabels();
legendDummies = NaN(numel(categories) + numel(modelNames) + 1, 1);
for category = 1:numel(categories)
    legendDummies(category) = ...
        plot(NaN, NaN, ['-' ' '], 'Color', colors{category});
end
for modelType = 1:numel(modelNames)
    legendDummies(numel(categories) + modelType) = ...
        plot(NaN, NaN, [modelLines{modelType} 'k', modelMarkers{modelType}]);
end
legendDummies(end) = ...
    plot(NaN, NaN, '-k ');
legend(legendDummies, [categories; modelNames; 'human'], 'Location', 'northwest');
end

