% Compare subjects
b = load('curBoltzmann.mat');
tData = b.tData;
dc = b.dc;
freq = b.freq;
voltage = b.voltage;
passed = b.passed;
sessionComparison;
b_65_10 = ses10_65;
b_65_100 = ses100_65;

e = load('curEuler.mat');
tData = e.tData;
dc = e.dc;
freq = e.freq;
voltage = e.voltage;
passed = e.passed;
sessionComparison;
e_65_10 = ses10_65;
e_65_100 = ses100_65;
%%
generateErrBars(100*e_65_10,100*b_65_10,nan,...
    100*e_65_100,100*b_65_100,...
    'xlabels',{'Euler 10%','Boltzmann 10%','','Euler 100%','Boltzmann 100%'},...
    'compareTo',50,'yaxis',[40,60]);
ylabel('% Contralateral Choices')

text(1,5,['n=',num2str(length(e_65_10))]);
text(2,5,['n=',num2str(length(b_65_10))]);

text(4,5,['n=',num2str(length(e_65_100))]);
text(5,5,['n=',num2str(length(b_65_100))]);