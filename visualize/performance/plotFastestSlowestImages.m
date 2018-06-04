function plotFastestSlowestImages(timeResultsHop)
rng(0);
timeResultsHop = changeResults(timeResultsHop, 'name', @(r) changeT0Name(r));

%% fastest model
t0Results = filterResults(timeResultsHop, @(r) strcmp(r.name, 'caffenet_fc7-bipolar0-hop_t0-libsvmccv'));
t0Results = collapseResults(t0Results);
fastestModel = t0Results(logical(t0Results.correct), :);
fprintf('model: %d images solved at t0\n', size(fastestModel, 1));

%% slowest model
t64Results = filterResults(timeResultsHop, @(r) strcmp(r.name, 'caffenet_fc7-bipolar0-hop_t64-libsvmccv'));
t64Results = collapseResults(t64Results);
t256Results = filterResults(timeResultsHop, @(r) strcmp(r.name, 'caffenet_fc7-bipolar0-hop_t256-libsvmccv'));
t256Results = collapseResults(t256Results);
slowestModel = t256Results(logical(t256Results.correct) & ~logical(t64Results.correct), :);
fprintf('model: %d images solved at t256 but not at t64\n', size(slowestModel, 1));
save('fastestSlowestModel.mat', 'fastestModel', 'slowestModel');

%% second-slowest model
t32Results = filterResults(timeResultsHop, @(r) strcmp(r.name, 'caffenet_fc7-bipolar0-hop_t32-libsvmccv'));
t32Results = collapseResults(t32Results);
secondSlowestModel = t64Results(logical(t64Results.correct) & ~logical(t32Results.correct), :);
fprintf('model: %d images solved at t64 but not at t32\n', size(secondSlowestModel, 1));
save('fastestSlowestModel.mat', 'fastestModel', 'slowestModel', 'secondSlowestModel');

%% plot
plotImages(fastestModel, 1, 3, 10);
plotImages(slowestModel, 2, 3, 10);
plotImages(secondSlowestModel, 3, 3, 10);
end

function plotImages(rows, numRow, numRows, numColumns)
if size(rows, 1) > numColumns
    rows = rows(randsample(size(rows, 1), numColumns), :);
end
images = collectImages(rows);
for numCol = 1:numel(images)
    subplot(numRows, numColumns, (numRow - 1) * numColumns + numCol);
    imshow(images{numCol});
end
end

function names = changeT0Name(results)
names = results.name;
for i = 1:numel(names)
    if strcmp(names{i}, 'caffenet_fc7_t0')
        names{i} = 'caffenet_fc7-bipolar0-hop_t0-libsvmccv';
    end
end
end

function images = collectImages(imageRows)
images = cell([size(imageRows, 1), 1]);
for i = 1:numel(images)
    images{i} = createOccludedImage(imageRows.testrows(i), false);
end
end
