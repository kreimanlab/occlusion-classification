function plotRnnMaskingOverTime(results)
for mask = 0:5
    currentResults = filterResults(results, ...
        @(r) cell2mat(cellfun(@(s) ~isempty(s), ...
        strfind(r.name, sprintf('mask%d', mask)), 'UniformOutput', false)));
    [~, text] = plotOverallPerformanceOverTime(currentResults);
    hold on;
    text = get(text, 'Text');
    text.String = sprintf('%s-mask%d', text.String, mask);
end
end
