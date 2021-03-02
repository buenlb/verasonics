function estimval = modelSigmoid_ext(variables)
%Estimate parameters of this model (see srrPlotCells for description of
%models)

global x;
global y;

%interface
slope = variables(1);
bias = variables(2);
upshift = variables(3);
scale = variables(4);

y_fit = sigmoid_ext(x, slope, bias, upshift, scale);

estimval = (y - y_fit) * (y - y_fit)';
