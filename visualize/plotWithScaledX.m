function [plots, scaledX] = plotWithScaledX(timesteps, Y, E, ...
    plotFnc, plotArgs)
if ~exist('E', 'var')
    E = NaN(size(Y));
end
if ~exist('plotFnc', 'var')
    plotFnc = @plot;
end
if ~exist('plotArgs', 'var')
    plotArgs = {'o-'};
end
maxX = size(Y, 2);
scaledX = cell(size(timesteps, 1), 1);
plots = cell(size(timesteps, 1));
for modelType = 1:size(timesteps, 1)
    nonNaN = ~isnan(Y(modelType, :));
    scaledX{modelType} = 1:((maxX - 1) / (sum(nonNaN) - 1)):maxX;
    if size(plotArgs, 1) > 1
        currentPlotArgs = {plotArgs{modelType, :}};
    else
        currentPlotArgs = plotArgs;
    end
    if any(~isnan(E(:)))
        p = plotFnc(scaledX{modelType}, Y(modelType, nonNaN), ...
            E(modelType, nonNaN), currentPlotArgs{:});
    else
        p = plotFnc(scaledX{modelType}, Y(modelType, nonNaN), ...
            currentPlotArgs{:});
    end
    hold on;
    plots{modelType} = p;
end
[xlabels, xticks] = makeXLabels(timesteps, scaledX);
my_xticklabels(xticks, xlabels);
hold off;
end
