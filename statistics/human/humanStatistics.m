function humanStatistics()
rng(0, 'twister');
data = load('data/data_occlusion_klab325v2.mat');
data = data.data;
newData = load('data/data_occlusion_klab325v3.mat');
newData = newData.data;
filteredData = filterHumanData(data);
filteredNewData = filterHumanData(newData);
% 100% vs 35% visibility
visibility100 = filteredNewData.correct(filteredNewData.occluded == 0);
visibility35 = getCorrect(filteredData, 35 - 2.5, 99);
[h, p] = ttest2(visibility35, visibility100);
assert(h == 1);
fprintf('35%% visibility: %.2f%% +- %.2f%%, != 100%%: p=%d\n', ...
    100 * mean(visibility35), 100 * stderrmean(visibility35), p);

% 10% visibility vs chance
visibility10 = getCorrect(filteredData, 10 - 2.5, 10 + 2.5);
chance = ones(size(visibility10));
chance(randsample(numel(chance), round(0.8 * numel(chance)))) = 0;
[h, p] = ttest2(visibility10, chance);
assert(h == 1);
fprintf('10%% visibility: %.2f%% +- %.2f%%, != chance: p=%d\n', ...
    100 * mean(visibility10), 100 * stderrmean(visibility10), p);

% occluder vs partial
occluder = filteredNewData.correct(filteredNewData.partial == 0);
partial = filteredNewData.correct(filteredNewData.partial == 1);
[h, p] = ttest2(occluder, partial);
assert(h == 1);
fprintf('occluder != partial: p=%d\n', p);

% soa influence on performance
soas = unique(data.soa)';
for soa = soas
    unmaskedPerformance = data.correct(...
        data.soa == soa & data.masked == 0);
    maskedPerformance = data.correct(...
        data.soa == soa & data.masked == 1);
    [h, p] = ttest2(unmaskedPerformance, maskedPerformance);
    fprintf('%.3f soa: ttest2 = %d, p = %d\n', soa, h, p);
end
end

function correct = getCorrect(data, visibilityLeft, visibilityRight)
correct = data.correct(...
    data.black >= 100 - visibilityRight & ...
    data.black <= 100 - visibilityLeft);
end
