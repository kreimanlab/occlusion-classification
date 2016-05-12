function occludedImages = occlude(images, dataSelection, occlusionData)

bub_sig = 14;
occludedImages = cell(length(images), 1);
for i = 1:length(images)
    row = dataSelection(i);
    numBubbles = occlusionData.nbubbles(row);
    S.c = occlusionData.bubble_centers(row, 1:numBubbles);
    S.sig = bub_sig * ones(1, numBubbles);
    occludedImages{i} = AddBubble(images{i}, S);
end
