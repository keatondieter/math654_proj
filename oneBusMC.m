clear
close all
clc

% Normally distributed random varaiable zero mean, unit variance
mu = 0;
sigma = 1;

% Load in the power system case
filecontents = load('case300_psse.mat');
mpc = filecontents.mpc;

mpopt = mpoption('verbose', 0, 'out.all', 0, 'pf.enforce_q_lims', 1);
pfBase = runpf(mpc, mpopt);
    
numBuses = length(mpc.bus(:,1));
numGen = length(mpc.gen(:,1));

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

N = 1000;
means = zeros(numBuses, numGen);
stds = zeros(numBuses, numGen);

for i = 1:2
    baseLoad = pfBase.bus(i, 4);

    % Test monte-carlo
    X = normrnd(mu, sigma, N, 1);

    genRes = zeros(length(mpc.gen(:,1)), N);
    pfSuccess = zeros(N,1);
    loadVal = zeros(N, 1);
    j = 1;
    for x = X'
        % Reset to the base case
        mpc = pfBase;

        % Set the new load value
        curLoad = baseLoad + sysMu * x * 0.5; 
        mpc.bus(i, 4) = curLoad;

        % Run the power flow
        pfRes = runpf(mpc, mpopt);

        loadVal(j) = curLoad;
        pfSuccess(j) = pfRes.success;
        genRes(:,j) = pfRes.gen(:,3);
        j = j + 1;
    end
    
    means(i,:) = mean(genRes, 2);
    stds(i,:) = std(genRes, 0, 2)'; 
end

save('monteCarlo.mat', 'means', 'stds');

