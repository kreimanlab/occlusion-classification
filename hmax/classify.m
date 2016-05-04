function [predicted_classes] = ...
    classify(stored_output)

USE_SAVED_C2TEST=true;
USE_SAVED_PREDICTION=true;

%% Load previous output
if (nargin < 1)
    stored_output = './output/exampleActivations.mat';
end
load(stored_output);
load('./exampleImages.mat'); % for the image filenames and testing

% determine labels
image_filenames = exampleImages;
labels = get_labels_from_files(image_filenames);
% prepare input (c2)
c2_bands_pool = poolC2(c2);
assert(length(labels) == size(c2_bands_pool,1));
% prepare input (c1)
%     c1_bands_pool = cell(size(c1))
%     for i=1:length(c1_bands_pool)
%         c1_bands_pool{1,i} = zeros(size(c1{1,i}{1,1}));
%         c1_bands_pool{1,i}(:) = max(c1{1,i}{:});
%     end

%% fit
classifier = fitcecoc(c2_bands_pool,labels);

%% test
% predict
test_imgs=exampleImages;
saved_c2test_file='./output-test/exampleActivations.mat';
if USE_SAVED_C2TEST
    load(saved_c2test_file);
else
    [c2_test,c1_test]=example(test_imgs,'./output-test/');
end
saved_predictions_file='./output-test/predictions.mat';
if USE_SAVED_PREDICTION
    load(saved_predictions_file);
else
    c2_test_bands_pool = poolC2(c2_test);
    predicted_labels=classifier.predict(c2_test_bands_pool);
    save(saved_predictions_file, 'c2_test_bands_pool', 'predicted_labels');
end
% analyze
real_test_labels = get_labels_from_files(test_imgs);
results = cell(length(test_imgs),1);
results(:) = {'ERR'};
for i=1:length(test_imgs)
    if predicted_labels{i} == real_test_labels{i}
        results{i} = 'OK';
    end
end
zipped_results=[results(:)';predicted_labels(:)';real_test_labels(:)'];
fprintf('[%s] Prediction: %s | Real: %s\n', zipped_results{:});
end
