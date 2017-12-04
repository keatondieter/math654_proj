clear
close all
clc

% Load in the power system case
filecontents = load('case300_psse.mat');
mpc = filecontents.mpc;

% Grab the active and reactive power demand data
demandP = mpc.bus(:,3);
demandQ = mpc.bus(:,3);

demandQ = demandQ + abs(min(demandQ)) + 1

histogram(demandQ, 75, 'Normalization', 'pdf')
x = ceil(min(demandQ)):1:ceil(max(demandQ));
for distname = {'Normal', 'Lognormal', 'Weibull', 'Exponential'}
    disp(distname{1})
    dist =  fitdist(demandQ, distname{1});
   
    distPdf = pdf(dist, x);
    
    hold on
    plot(distPdf)
    
end

legend('Real','Normal', 'Lognormal', 'Weibull', 'Exponential')
