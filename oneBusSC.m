clear
close all
clc

init_matpower_proj

% Load in the power system case
filecontents = load('case300_psse.mat');
mpcBase = filecontents.mpc;
mpc = mpcBase;

mpopt = mpoption('verbose', 0, 'out.all', 0, 'pf.enforce_q_lims', 1);
pfBase = runpf(mpcBase, mpopt);

voltages.dist = [0.6, 2.3, 6.6, 13.8, 16.5];
voltages.subtrans = [20, 27, 66, 86];
voltages.trans = [115, 138, 230, 345];

distBuses = getBusesAtLevels(mpcBase, voltages.dist);
distMean = mean(mpc.bus(distBuses,4));

subtransBuses = getBusesAtLevels(mpcBase, voltages.subtrans); 
subtransMean = mean(mpc.bus(subtransBuses,4));

transBuses = getBusesAtLevels(mpcBase, voltages.trans);
transMean = mean(mpc.bus([transBuses],4));

sysMu = zeros(length(mpc.bus(:,4)), 1);
sysMu(distBuses) = distMean;
sysMu(subtransBuses) = subtransMean;
sysMu(transBuses) = transMean;

numBuses = length(mpc.bus(:,1));
numGen = length(mpc.gen(:,1));

maxLevel = 1;
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

        curLoad = baseLoad + sysMu(i) * nodes(j) * 0.5;
        mpc.bus(i, 4) = curLoad;
    
        try
           pfRes = runpf(mpc, mpopt);
        catch
            disp(i)
            disp('reset to base')
            mpc = mpcBase;
            mpc.bus(i, 4) = curLoad;
            loadVal(j) = curLoad;
            colSuccess(j) = 0;
            
            try
                pfRes = runpf(mpc, mpopt);
            catch
                colSuccess(j) = 0;
                disp(i)
                disp(curLoad)
                disp('Tried them all')
            end
        end
        colSuccess(j) = pfRes.success;
        if colSuccess(j) == 0
            disp(curLoad)
        end
        genResCol = genResCol + pfRes.gen(:,3) * weights(j);
        genRes2 = genRes2 + pfRes.gen(:,3).^2 * weights(j);
        
        loadVal(j) = curLoad;
        colSuccess(j) = pfRes.success;
        genResCol = genResCol + pfRes.gen(:,3) * weights(j);

        genRes2 = genRes2 + pfRes.gen(:,3).^2 * weights(j);
    end
        
    success(i,:) = colSuccess;
    means(i,:) = genResCol;
    stds(i,:) = sqrt(genRes2 - genResCol.^2);

end

save(sprintf('sc_%d', maxLevel), 'means', 'stds', 'success');

