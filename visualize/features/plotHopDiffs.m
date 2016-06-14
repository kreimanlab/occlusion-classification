function plotHopDiffs(timesteps, ...
    totalAbsDiffs, absDiffsPerFeature, absDiffsPerObject, absDiffsPerImage)

figure();
subplot(1, 4, 1);
plotHopConvergence(timesteps, totalAbsDiffs);
xlabel('Time');
ylabel('Total absolute difference');

subplot(1, 4, 2);
imagesc(absDiffsPerFeature');
colorbar;
title('features');
xlabel('Time');
ylabel('feature');
set(gca, 'XTickLabel', '');

subplot(1, 4, 3);
imagesc(absDiffsPerImage');
colorbar;
title('images');
xlabel('Time');
ylabel('row');
set(gca, 'XTickLabel', '');

subplot(1, 4, 4);
imagesc(absDiffsPerObject');
colorbar;
title('objects');
xlabel('Time');
ylabel('pres');
set(gca, 'XTickLabel', '');
end
