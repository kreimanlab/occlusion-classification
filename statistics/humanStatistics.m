function humanStatistics()
data = load('data/data_occlusion_klab325v2.mat');
data = data.data(data.data.pres <= 300, :);
unmaskedData = data(data.masked == 0, :);
newData = load('data/data_occlusion_klab325v3.mat');
newData = newData.data(newData.data.pres <= 300, :);
unmaskedNewData = newData(newData.masked == 0, :);

%% 100% vs 35% visibility
visibility100 = unmaskedNewData.correct(unmaskedNewData.occluded == 0);
visibility35 = getCorrect(unmaskedData, 35);
[h, p] = ttest2(visibility35, visibility100);
assert(h == 1);
fprintf('[2A] 35%% visibility: %.0f%% +- %.0f%%, != 100%%: p=%d\n', ...
    100 * mean(visibility35), 100 * stderrmean(visibility35), p);

%% 10% visibility vs chance
visibility10 = getCorrect(unmaskedData, 10);
chance = ones(size(visibility10));
chance(randsample(numel(chance), round(0.8 * numel(chance)))) = 0;
[h, p] = ttest2(visibility10, chance);
assert(h == 1);
fprintf('[2A] 10%% visibility: %.0f%% +- %.0f%%, != chance: p=%d\n', ...
    100 * mean(visibility10), 100 * stderrmean(visibility10), p);

%% partial vs occluder
occluder = newData(newData.masked == 1 & newData.partial == 0, :);
occluderMeanCorrectPerSoa = ...
    arrayfun(@(soa) mean(occluder.correct(occluder.soa == soa)), ...
    unique(occluder.soa));
partial = newData(newData.masked == 1 & newData.partial == 1, :);
partialMeanCorrectPerSoa = ...
    arrayfun(@(soa) mean(partial.correct(partial.soa == soa)), ...
    unique(partial.soa));
[~, ~, p] = crosstab(occluderMeanCorrectPerSoa, partialMeanCorrectPerSoa);
fprintf('[S1A/B] partial (n=%d) != occluded (n=%d): p=%.4f\n', ...
    numel(unique(partial.subject)), numel(unique(occluder.subject)), p);

%% soa influence on performance
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

function correct = getCorrect(data, visibility)
visibilityLeft = visibility - 5;
visibilityRight = visibility;
correct = data.correct(...
    data.black >= 100 - visibilityRight & ...
    data.black <= 100 - visibilityLeft);
end

function [score, degreesOfFreedom, p] = chisq(O, E)
assert(numel(O) == numel(E));
score = sum(arrayfun(@(i) pow2(O(i) - E(i)) / E(i), 1:numel(O)));
degreesOfFreedom = (2 - 1) * (numel(O) - 1); % vars-1 * observations-1
p = chi2cdf(score, degreesOfFreedom);
end
