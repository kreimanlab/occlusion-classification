function [blackMin, blackMax, blackCenter, intervalLeft, intervalRight] = ...
    getPercentBlackRange(percentsBlack, i)
blackMin = percentsBlack(i);
blackMax = 100;
if i < length(percentsBlack)
    blackMax = percentsBlack(i + 1);
end
blackCenter = (blackMin + blackMax) / 2;
intervalLeft = blackCenter - blackMin;
intervalRight = blackMax - blackCenter;
end
