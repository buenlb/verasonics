function setDelays_focalImage(RData) %#ok<INUSD>
%% Get relevant structures from the base of the stack
Resource = evalin('base','Resource');
Trans = evalin('base','Trans');
TX = evalin('base','TX');

%% Determine which focus the system is on
curIdx = Resource.Parameters.curIdx+1;
x = Resource.Parameters.x;
y = Resource.Parameters.y;
z = Resource.Parameters.z;
if curIdx > length(z)
    curIdx = 1;
end

xTx = Trans.ElementPos(:,1);
yTx = Trans.ElementPos(:,2);
zTx = Trans.ElementPos(:,3);

elements.x = xTx*1e-3;
elements.y = yTx*1e-3;
elements.z = zTx*1e-3;

idx = 1;
for ii = 1:length(x)
    for jj = 1:length(y)
        elements = steerArray(elements,[x(ii),y(jj),z(curIdx)]*1e-3,Trans.frequency,0);
        delays = [elements.t]';
        TX(idx).Delay = delays;
        idx = idx+1;
    end
end

Resource.Parameters.curIdx = curIdx;
% disp(['Index: ', num2str(Resource.Parameters.curIdx)])
if Resource.Parameters.curIdx > length(z)
    Resource.Parameters.curIdx = 1;
end

%% Update them in base
assignin('base','TX', TX);
assignin('base','Resource', Resource);
% Set Control command to update TX
Control = evalin('base','Control');
Control.Command = 'update&Run';
Control.Parameters = {'TX'};
assignin('base','Control', Control);

t = toc;
disp(['Assigned Phases, elapsed time', num2str(round(t))])