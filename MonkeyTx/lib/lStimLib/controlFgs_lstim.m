function controlFgs_lstim(fg,voltage,nBlocks)
fg1 = fg(1);

blocks = {'LEDS','US+LEDS','US'};
for n = 1:nBlocks
    for ii = 1:length(voltage)
        for jj = 1:length(blocks)
            disp(['BLOCK: ', blocks{jj}])
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