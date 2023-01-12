function controlFgs_lstimVerasonics(~)
Resource = evalin('base','Resource');

fg1 = Resource.Parameters.fgs(1);
% fg2 = Resource.Parameters.fgs(2);
voltage = Resource.Parameters.voltages;
nBlocks = Resource.Parameters.nBlocks;

blocks = {'LEDS','US+LEDS','US'};
for n = 1:nBlocks
    disp(['BLOCK ', num2str(n), ' of ', num2str(nBlocks)]);
    for ii = 1:length(voltage)
        for jj = 1:length(blocks)
            disp(['  SUB-BLOCK: ', blocks{jj}])
            switch blocks{jj}
                case 'LEDS'
                    % Trigger
                    fgTrigger(fg1,1);
                    pause(30.3);
                    checkFgError(fg1);
                case 'US+LEDS'
                    % Trigger
                    fgTrigger(fg1);
                    pause(30.3);
                    checkFgError(fg1);
                case 'US'
                    % Trigger
                    fgTrigger(fg1,2);
                    pause(30.3);
                    checkFgError(fg1);
                otherwise
                    error('Unrecognized Block Type')
            end
        end
    end
end

fclose(fg1);

disp('Finished')
closeVSX();
return