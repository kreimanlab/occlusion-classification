function results = evaluate(dataset, percentsVisible, visibilityMargin, ...
    classifiers, trainPres, testPres)
results = cell(length(percentsVisible), length(classifiers));
for iClassifier = 1:length(classifiers)
    classifier = classifiers{iClassifier};
    fprintf('Training %s on whole images...\n', classifier.getName());
    trainRows = getRows(dataset, trainPres, true);
    trainLabels = dataset.truth(trainRows);
    classifier.train(trainRows, trainLabels);
    
    for iPv = 1:length(percentsVisible)
        fprintf('Testing %s on %d percent visibility\n', ...
            classifier.getName(), percentsVisible(iPv));
        testRows = getRows(dataset, testPres, false);
        percentBlack = 100 - percentsVisible(iPv);
        testRows = testRows(...
            dataset.black(testRows) >  percentBlack - visibilityMargin &...
            dataset.black(testRows) <= percentBlack + visibilityMargin);
        testLabels = dataset.truth(testRows);
        predictedLabels = classifier.predict(testRows);
        % analyze
        [matched, accuracy] = analyzeResults(predictedLabels, testLabels);
        results{iPv, iClassifier} = struct('name', classifier.getName(), ...
            'predicted', predictedLabels, 'real', testLabels,...
            'matched', matched, 'accuracy', accuracy);
    end
end
results = {cell2mat(results)};
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
