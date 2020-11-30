function E = totalEnergy(sys)
E = 0;
for ii = 1:length(sys.sonication)
    E = E + sys.sonication(ii).duration*sys.sonication(ii).voltage^2;
end
maxE = 481*60;
disp(['Total Energy: ', num2str(E), ' V^2/s (', num2str(100*E/maxE), '% of ', num2str(maxE), ' V^2/s)'])