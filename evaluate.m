function results = evaluate(dataset, classifiers, getLabels, trainPres, testPres)
for iClassifier = 1:numel(classifiers)
    classifier = classifiers{iClassifier};
    fprintf('Training %s on whole images...\n', classifier.getName());
    trainRows = getRows(dataset, trainPres, true);
    trainLabels = getLabels(dataset, trainRows);
    classifier.train(trainRows, trainLabels);
    
    fprintf('Testing %s on occluded images\n', classifier.getName());
    testRows = getRows(dataset, testPres, false);
    testLabels = getLabels(dataset, testRows);
    predictedLabels = classifier.predict(testRows);
    % analyze
    correct = analyzeResults(predictedLabels, testLabels);
    currentResults = struct2dataset(struct(...
        'name', {repmat({classifier.getName()}, length(testRows), 1)}, ...
        'pres', dataset.pres(testRows), ...
        'response', predictedLabels, 'truth', testLabels,...
        'correct', correct, 'black', dataset.black(testRows)));
    if ~exist('results', 'var')
        results = currentResults;
    else
        results = [results; currentResults];
    end
end
results = {results}; % box for encapsulating cross validation
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
