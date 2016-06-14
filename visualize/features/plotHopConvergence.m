function plotHopConvergence(timesteps, totalAbsDiffs)
semilogy(timesteps, totalAbsDiffs, '-ok', 'MarkerSize', 2);
hold on;
zeroIndices = find(totalAbsDiffs == 0);
scatter(timesteps(zeroIndices), totalAbsDiffs(zeroIndices), 'rx');
ylabel('Total absolute feature difference from previous timestep');
end
