function plotHopDiffs(absDiffsPerFeature, absDiffsPerObject, absDiffsPerImage)
figure();
subplot(1, 3, 1);
imagesc(absDiffsPerFeature');
colorbar;
title('features');
subplot(1, 3, 2);
imagesc(absDiffsPerImage');
colorbar;
title('images');
subplot(1, 3, 3);
imagesc(absDiffsPerObject');
colorbar;
title('objects');
end
