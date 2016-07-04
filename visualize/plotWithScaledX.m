function plots = plotWithScaledX(timesteps, Y)
maxX = size(Y, 2);
scaledX = cell(size(timesteps, 1), 1);
plots = cell(size(timesteps, 1));
for modelType = 1:size(timesteps, 1)
    nonNaN = ~isnan(Y(modelType, :));
    scaledX{modelType} = 1:((maxX-1)/(sum(nonNaN)-1)):maxX;
    p = plot(scaledX{modelType}, Y(modelType, nonNaN), 'o-');
    hold on;
    plots{modelType} = p;
end
[xlabels, xticks] = makeXLabels(scaledX, timesteps);
my_xticklabels(xticks, xlabels);
hold off;
end

