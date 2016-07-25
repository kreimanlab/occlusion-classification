function [xlabels, xticks] = makeXLabels(timesteps, xticks)
if ~exist('xticks', 'var')
    xlabels = arrayfun(@(i) ...
        strjoin(cellstr(makeStrPlain(timesteps(:, i))), '\n'), ...
        1:size(timesteps, 2), ...
        'UniformOutput', false);
    return;
end

assert(size(xticks, 1) == size(timesteps, 1));
% remove duplicates
for row = size(timesteps, 1):-1:1
    for otherRow = row + 1:size(timesteps, 1)
        if isequaln(timesteps(otherRow, :), timesteps(row, :)) ...
                && all(xticks{otherRow, :} == xticks{row, :})
            timesteps(row, :) = [];
            xticks(row, :) = [];
            break;
        end
    end
end
% retrieve unique
uniqueXTicks = unique(cell2mat(cellfun(@(c) c', xticks, ...
    'UniformOutput', false)));
timestepForTick = cell(size(timesteps));
for row = 1:size(timestepForTick, 1)
    modelTickIter = 1;
    rowXTicks = xticks{row};
    for uniqueTickIter = 1:numel(uniqueXTicks)
        if rowXTicks(modelTickIter) == uniqueXTicks(uniqueTickIter)
            timestepForTick{row, uniqueTickIter} = ...
                timesteps(row, modelTickIter);
            modelTickIter = modelTickIter + 1;
        end
    end
end
% stringify
xlabels = arrayfun(@(i) ...
    strjoin(cellstr(makeStr(timestepForTick(:, i))), '\n'), ...
    1:size(timestepForTick, 2), ...
    'UniformOutput', false);
xticks = uniqueXTicks;
end

function str = makeStr(timesteps)
str = repmat(' ', size(timesteps, 1), 3);
for row = 1:size(timesteps, 1)
    if ~isempty(timesteps{row}) && ~any(isnan(timesteps{row}))
        str(row, :) = sprintf('%3d', timesteps{row});
    end
end
end

function str = makeStrPlain(timestep)
str = num2str(timestep);
for row = 1:size(str, 1)
    str(row, :) = strrep(str(row, :), 'NaN', '   ');
end
end
