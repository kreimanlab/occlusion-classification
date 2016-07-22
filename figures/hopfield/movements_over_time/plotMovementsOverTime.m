function plotMovementsOverTime()
% T = [1; -1]; % 1 attractor
% T = [1 -1; -1 1]; % 2 attractors
% T = [1 1; 1 -1]; % 2 attractors
% T = [1 1 -1; -1 1 -1]; % 3 attractors
T = [1 1 -1 -1; -1 1 -1 1]; % 4 attractors
for xi = 1:size(T, 2)
    plot(T(1, xi), T(2, xi), 'o', 'MarkerSize', 10);
    hold on;
end
xlim([-1.2, 1.2]);
ylim([-1.2, 1.2]);

net = newhop(T);

timesteps = 10;
[xs,ys] = meshgrid(-1:0.05:1,-1:0.05:1);
in = [xs(:)';ys(:)'];
plot(in(1, :), in(2, :), 'x');
Y = net(cell(1,timesteps),{},{in});
prevY = in;
for t = 1:timesteps
    y = Y{t};
    quiver(prevY(1, :), prevY(2, :), ...
        y(1, :) - prevY(1, :), y(2, :) - prevY(2, :), 'b');
    prevY = y;
end
end
