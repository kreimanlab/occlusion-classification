function results = evaluate(task, dataset, classifiers, getLabels, ...
    trainPres, testPres)
if strcmp(task, 'identification')
    testPres = trainPres;
end
trainRows = getRows(dataset, trainPres, true);
trainLabels = getLabels(dataset, trainRows);
testRows = getRows(dataset, testPres, false);
testPresAll = dataset.pres(testRows);
testBlack = dataset.black(testRows);
testLabels = getLabels(dataset, testRows);
results = cell(numel(classifiers), 1);
parfor iClassifier = 1:numel(classifiers)
    classifier = classifiers{iClassifier};
    fprintf('Training %s on whole images...\n', classifier.getName());
    classifier.train(trainRows, trainLabels);
    fprintf('Testing %s on occluded images\n', classifier.getName());
    predictedLabels = classifier.predict(testRows);
    % analyze
    correct = analyzeResults(predictedLabels, testLabels);
    currentResults = struct2dataset(struct(...
        'name', {repmat({classifier.getName()}, length(testRows), 1)}, ...
        'pres', testPresAll, 'black', testBlack, ...
        'response', predictedLabels, 'truth', testLabels, ...
        'correct', correct));
    results(iClassifier) = {currentResults};
end
% merge datasets and box for encapsulating cross validation
results = {vertcat(results{:})};
end

function rows = getRows(dataset, pres, uniqueRows)
if uniqueRows
    [~, rows] = unique(dataset, 'pres');
else
    rows = 1:size(dataset, 1);
end
rows = rows(ismember(dataset.pres(rows), pres));
assert(all(sort(unique(dataset.pres(rows))) == sort(pres)));
if uniqueRows
    assert(length(rows) == length(pres));
end
end
