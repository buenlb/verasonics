function cost = sigmoidCost(x,y,delays)

slope = x(1);
bias = x(2);
upshift = x(3);
scale = x(4);

y_fit = sigmoid_ext(delays, slope, bias, upshift, scale);
cost = norm(y_fit-y);
