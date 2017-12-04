clear
close all
clc

% Test looking at bus random bus
busNo = unidrnd(300);

% Load in the power system case
filecontents = load('case300_psse.mat');
mpc = filecontents.mpc;

histogram(loadVal)

maxLevel = 2;
dimension = 1;

numPoints = sparse_grid_herm_size(dimension, maxLevel);
[weights, nodes] = sparse_grid_herm(dimension, maxLevel, numPoints);
weights = weights / sum(weights)

genResCol = zeros(length(mpc.gen(:,1)), 1);
colSuccess = zeros(numPoints, 1);
for i = 1:numPoints
    mpc = pfBase;
    
    load = baseLoad + sysMu * nodes(i);
    mpc.bus(busNo, 4) = load;
    
    pfRes = runpf(mpc, mpopt);
    
    loadVal(i) = load;
    colSuccess(i) = pfRes.success;
    genResCol = genResCol + pfRes.gen(:,3) * weights(i);
end

figure()
subplot(1,2,1)
bar(mean(genRes, 2))
title('Monte-Carlo')

subplot(1,2,2)
bar(genResCol)
title('Collocation')

shg

figure()
histogram(mean(genRes, 2) - genResCol)