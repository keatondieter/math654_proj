function busNos = getBusesAtLevels(mpc, levels)
    busNos = [];
    for level = levels
        busNos = [busNos, find(mpc.bus(:,10) == level)'];
    end 
end