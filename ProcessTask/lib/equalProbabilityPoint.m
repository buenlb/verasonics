function p = equalProbabilityPoint(slope,bias,upshift,scale)
p = log(scale/(0.5-upshift)-1)/(-slope)+bias;

if abs(imag(p))>0
    p = nan;
end