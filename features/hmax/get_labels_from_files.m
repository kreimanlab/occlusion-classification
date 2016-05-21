function [labels] = get_labels_from_files(files)
    labels = cell(length(files),1);
    for i = 1:length(files)
        filename = files(i);
        labels{i} = get_label_from_file(filename{1,1});
    end
    labels = labels(~cellfun(@isempty, labels));

function [label] = get_label_from_file(filename)
    [~,basename,~] = fileparts(filename);
    label = basename(1:end-5);