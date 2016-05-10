function occludedImages = occlude(images, percentVisible, occlusionData)

occludedImages = cell(length(images), 1);
for i = 1:length(images)
    numBubbles = occlusionData.nbubbles(i);
    S.c = occlusionData.bubble_centers(i, 1:numBubbles);
    S.sig = percentVisible * ones(1, numBubbles);
    occludedImages{i} = AddBubble(images{i}, S);
end
