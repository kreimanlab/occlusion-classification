function [predicted_classes] = ...
    classify(stored_output)

USE_SAVED_C2TEST=true;
USE_SAVED_PREDICTION=true;

%% Load previous output
if (nargin < 1)
    stored_output = './output/activations.mat';
end
load(stored_output);
load('./../data/data_occlusion_klab325v2_origimages.mat'); % labels

% determine labels
labels = [data.truth(1:5,1); data.truth(61:65,1)];
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
% prepare
load('../data/KLAB325.mat');
test_indices = [{1,1:5}; {1,61:65}];
test_imgs = [img_mat(test_indices{1,1},test_indices{1,2}),...
    img_mat(test_indices{2,1},test_indices{2,2})];
real_test_labels = [data.truth(test_indices{1,2},test_indices{1,1});...
    data.truth(test_indices{2,2},test_indices{2,1})];
% predict
saved_c2test_file='./output-test/activations.mat';
if USE_SAVED_C2TEST
    load(saved_c2test_file);
else
    [c2_test,c1_test]=train(test_imgs,'./output-test/');
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
results = cell(length(test_imgs),1);
results(:) = {'ERR'};
for i=1:length(test_imgs)
    if predicted_labels(i) == real_test_labels(i)
        results{i} = 'OK';
    end
end
zipped_results=[results(:)';...
    num2cell(predicted_labels(:)');...
    num2cell(real_test_labels(:)')];
fprintf('[%s] Prediction: %d | Real: %d\n', zipped_results{:});
end
