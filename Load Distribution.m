
% Load in the power system case
filecontents = load('case300_psse.mat');
mpc = filecontents.mpc;

% Grab the active and reactive power demand data
demandP = mpc.bus(:,3);
demandQ = mpc.bus(:,3);

histogram(demandQ, 75)
hold on
x = ceil(min(demandQ)):1:ceil(max(demandQ));
for distname = {'Eponential', 'Normal', 'Lognormal', 'Weibull'}
    dist =  fitdist(demandQ, distname)
    
    pdf = pdf(dist, x)
    
    plot(pdf)
    
end

legend('Eponential', 'Normal', 'Lognormal', 'Weibull')
