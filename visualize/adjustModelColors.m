function mappedModelColors = adjustModelColors(plots, plotModelNames, ...
    colorProperty)
assert(~iscell(plots));
if ~exist('colorProperty', 'var')
    colorProperty = 'Color';
end
[modelLabels, modelColors] = getModelLabels();
mappedModelColors = cell(size(plotModelNames));
for i = 1:numel(plots)
    matched = false;
    modelNameInPlot = plotModelNames{i};
    for l = 1:numel(modelLabels)
        if strcmp(modelNameInPlot, modelLabels{l})
            color = setColor(plots(i), colorProperty, modelColors{l});
            mappedModelColors{i} = color;
            matched = true;
            break;
        end
    end
    if ~matched
        warning('No match for %s', modelNameInPlot);
        try
            mappedModelColors{i} = get(plots(i), 'Color');
        catch
            warning('Failed to retrieve color from plot');
        end
    end
end
end

function color = setColor(plot, colorProperty, color)
if ischar(color)
    color = rgb(color);
end
set(plot, colorProperty, color);
end
