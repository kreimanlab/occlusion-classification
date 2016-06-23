function plotHopConvergence(timesteps, totalAbsDiffs, signChangesPerFeature)
semilogy(timesteps, totalAbsDiffs, '-ok', 'MarkerSize', 2);
hold on;
convergenceIndices = find(~any(signChangesPerFeature));
scatter(timesteps(convergenceIndices), ...
    totalAbsDiffs(convergenceIndices), 'rx');
ylabel('Total absolute feature difference from previous timestep');
end
