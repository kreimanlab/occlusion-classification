function xlabels = makeXLabels(timesteps)
xlabels = arrayfun(@(i) ...
    strjoin(cellstr(makeStr(timesteps(:, i))), '\n'), ...
    1:size(timesteps, 2), ...
    'UniformOutput', false);
end

function str = makeStr(timestep)
str = num2str(timestep);
for row = 1:size(str, 1)
    str(row, :) = strrep(str(row, :), 'NaN', '   ');
end
end
