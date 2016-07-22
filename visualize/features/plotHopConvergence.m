function plotHopConvergence(timesteps, totalAbsDiffs, signChangesPerFeature)
semilogy(timesteps, totalAbsDiffs, '-ok', 'MarkerSize', 2);
hold on;
noSignChangeIndices = find(~any(signChangesPerFeature'));
convergenceIndex = find(any(signChangesPerFeature'), 1, 'last') + 1;
scatter(timesteps(noSignChangeIndices), ...
    totalAbsDiffs(noSignChangeIndices), 'rx');
ylabel('Total absolute feature difference from previous timestep');
title(sprintf('Converge first at t=%d', timesteps(convergenceIndex)));
end
