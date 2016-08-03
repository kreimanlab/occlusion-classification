function [filteredData, relevantRows] = filterHumanData(data, keepSoas)
%FILTERHUMANDATA remove training, masked and unoccluded images, use only
%data where soa = 150ms
if ~exist('keepSoas', 'var')
    keepSoas = false;
end
relevantRows = ...
    data.pres <= 300 & ...
    data.masked == 0;
if ~keepSoas
    relevantRows = relevantRows & data.soa == .150;
end
filteredData = data(relevantRows, :);
end

