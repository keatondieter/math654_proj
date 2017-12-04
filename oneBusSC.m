clear
close all
clc

init_matpower_proj

% Load in the power system case
filecontents = load('case300_psse.mat');
mpc = filecontents.mpc;

mpopt = mpoption('verbose', 0, 'out.all', 0, 'pf.enforce_q_lims', 1);
pfBase = runpf(mpc, mpopt);

sysMu = mean(mpc.bus(:,4));

numBuses = length(mpc.bus(:,1));
numGen = length(mpc.gen(:,1));

maxLevel = 3;
dimension = 1;

numPoints = sparse_grid_herm_size(dimension, maxLevel);
[weights, nodes] = sparse_grid_herm(dimension, maxLevel, numPoints);
weights = weights / sum(weights);

for i = 1:300'
    

    genResCol = zeros(length(mpc.gen(:,1)), 1);
    genRes2 = zeros(length(mpc.gen(:,1)), 1);
    colSuccess = zeros(numPoints, 1);
    
    baseLoad = pfBase.bus(i,4);
    
    for j = 1:numPoints
        mpc = pfBase;

        curLoad = baseLoad + sysMu * nodes(j);
        mpc.bus(i, 4) = curLoad;

        pfRes = runpf(mpc, mpopt);

        loadVal(j) = curLoad;
        colSuccess(j) = pfRes.success;
        genResCol = genResCol + pfRes.gen(:,3) * weights(j);

        genRes2 = genRes2 + pfRes.gen(:,3).^2 * weights(j);
    end

    means(i,:) = genResCol;
    stds(i,:) = sqrt(genRes2 - genResCol.^2);

end

save(sprintf('sc_%d', maxLevel), 'means', 'stds');

