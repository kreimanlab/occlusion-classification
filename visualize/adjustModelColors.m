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
    for l = 1:numel(modelLabels)
        if strcmp(plotModelNames{i}, modelLabels{l})
            color = setColor(plots(i), colorProperty, modelColors{l});
            mappedModelColors{i} = color;
            matched = true;
            break;
        end
    end
    if ~matched
        mappedModelColors{i} = get(plots(i), 'Color');
    end
end
end

function color = setColor(plot, colorProperty, color)
if ischar(color)
    color = rgb(color);
end
set(plot, colorProperty, color);
end
