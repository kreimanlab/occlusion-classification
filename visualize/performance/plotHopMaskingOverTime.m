function plotHopMaskingOverTime(results)
for maskExp = [-1, 1:6]
    if maskExp == -1
        mask = 0;
        name = 'sumFeatures_alexnet-relu7-bipolar0_alexnet-relu7-masked-bipolar0-hop_t';
    else
        mask = 2^maskExp;
        name = sprintf('-hop_t%d_alexnet-relu7-masked', mask);
    end
    currentResults = filterResults(results, ...
        @(r) cell2mat(cellfun(@(s) ~isempty(s), ...
        strfind(r.name, name), 'UniformOutput', false)));
    [~, text] = plotOverallPerformanceOverTime(currentResults);
    hold on;
    text = get(text, 'Text');
    text.String = sprintf('%s-mask%d', text.String, mask);
end
end
