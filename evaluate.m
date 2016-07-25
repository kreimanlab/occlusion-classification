function results = evaluate(task, dataset, dataSelection, classifiers, ...
    getLabels, trainPres, testPres)
if strcmp(task, 'identification')
    testPres = trainPres;
end
trainRows = getRows(dataset, dataSelection, trainPres, true);
trainLabels = getLabels(dataset, trainRows);
testRows = getRows(dataset, dataSelection, testPres, false);
testPresAll = dataset.pres(testRows);
testBlack = dataset.black(testRows);
testLabels = getLabels(dataset, testRows);
results = cell(numel(classifiers), 1);
parfor iClassifier = 1:numel(classifiers)
    classifier = classifiers{iClassifier};
    fprintf('Training %s...\n', classifier.getName());
    classifier.train(trainRows, trainLabels);
    fprintf('Testing %s...\n', classifier.getName());
    predictedLabels = classifier.predict(testRows);
    % analyze
    correct = analyzeResults(predictedLabels, testLabels);
    currentResults = struct2dataset(struct(...
        'name', {repmat({classifier.getName()}, length(testRows), 1)}, ...
        'testrows', testRows', ...
        'pres', testPresAll, 'black', testBlack, ...
        'response', predictedLabels, 'truth', testLabels, ...
        'correct', correct));
    results(iClassifier) = {currentResults};
end
% merge datasets and box for encapsulating cross validation
results = {vertcat(results{:})};
end

function rows = getRows(dataset, dataSelection, pres, uniqueRows)
if uniqueRows
    selectedData = dataset(dataSelection, :);
    [~, rows] = unique(selectedData, 'pres');
    rows = dataSelection(rows);
else
    rows = dataSelection;
end
rows = rows(ismember(dataset.pres(rows), pres));
assert(all(sort(unique(dataset.pres(rows))) == sort(pres)));
if uniqueRows
    assert(length(rows) == length(pres));
end
end
