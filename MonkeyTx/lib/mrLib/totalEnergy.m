function E = totalEnergy(sys)
E = 0;
for ii = 1:length(sys.sonication)
    if isfield(sys.sonication(ii),'freq')
        switch sys.sonication(ii).freq
            case 0.48
                vMultiplier = 0.5;
            case 0.65
                vMultiplier = 1;
            otherwise
                error('Unrecognized Frequency')
        end
    else
        vMultiplier = 1;
    end
    E = E + sys.sonication(ii).duration*(vMultiplier*sys.sonication(ii).voltage)^2;
end
maxE = 481*60;
disp(['Total Energy: ', num2str(E), ' V^2s (', num2str(100*E/maxE), '% of ', num2str(maxE), ' V^2s)'])