function y = sigmoid_ext(x, beta, bias, upshift, scale)

if nargin < 5,
    scale = 1;
end
y = scale ./ (1 + exp(-beta .* (x - bias))) + upshift;