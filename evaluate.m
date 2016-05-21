function results = evaluate(classifiers, ...
    trainX, trainY, testX, testY)
results = cell(length(classifiers), 1);
for iClassifier = 1:length(classifiers)
    classifier = classifiers{iClassifier};
    fprintf('Training %s...\n', classifier.getName());
    classifier.train(trainX, trainY);

    fprintf('Testing %s...\n', classifier.getName());
    predictedY = classifier.predict(testX);
    % analyze
    [matched, accuracy] = analyzeResults(predictedY, testY);
    results{iClassifier} = struct('name', classifier.getName(), ...
        'predicted', predictedY, 'real', testY,...
        'matched', matched, 'accuracy', accuracy);
end
