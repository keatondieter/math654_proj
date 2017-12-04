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

sysMu = mean(mpc.bus(:,4));
N = 1000;
means = zeros(numBuses, 1);
stds = zeros(numBuses, 1);

for i = 1:2
    baseLoad = pfBase.bus(i, 4);

    % Test monte-carlo
    X = normrnd(mu, sigma, N, 1);

    genRes = zeros(length(mpc.gen(:,1)), N);
    pfSuccess = zeros(N,1);
    loadVal = zeros(N, 1);
    i = 1;
    for x = X'
        % Reset to the base case
        mpc = pfBase;

        % Set the new load value
        load = baseLoad + sysMu * x;
        mpc.bus(i, 4) = load;

        % Run the power flow
        pfRes = runpf(mpc, mpopt);

        loadVal(i) = load;
        pfSuccess(i) = pfRes.success;
        genRes(:,i) = pfRes.gen(:,3);
        i = i + 1;
    end
    
    means(i) = means(genRes, 2);
    stds(i) = std(genRes); 
end



