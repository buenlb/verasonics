PRF = 5e3;
distance = 7e-2;
c = 1540;
fs = 6.5e6;
bytesPerSample = 4;
totalTime = 330;

total = PRF*distance*2/c*fs*bytesPerSample*totalTime;
perSecond = PRF*distance*2/c*fs*bytesPerSample;

disp(['Total Data: ', num2str(total/1e6), ' Mb']) 
disp(['Per Second Data: ', num2str(perSecond/1e6), ' Mb'])