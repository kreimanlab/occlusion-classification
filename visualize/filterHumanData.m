function [filteredData, relevantRows] = filterHumanData(data, keepSoas, keepMasked)
%FILTERHUMANDATA remove training, masked and unoccluded images, use only
%data where soa = 150ms
if ~exist('keepSoas', 'var')
    keepSoas = false;
end
if ~exist('keepMasked', 'var')
    keepMasked = false;
end
relevantRows = data.pres <= 300;
relevantRows = relevantRows & data.masked == keepMasked;
if ~keepSoas
    relevantRows = relevantRows & data.soa == .150;
end
filteredData = data(relevantRows, :);
end

