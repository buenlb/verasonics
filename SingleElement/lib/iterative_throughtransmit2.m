function iterative_throughtransmit2()

STARTX = -40; %start at the broadest parts of the skull (at which L and R surfaces are parallel to each other)
alpha = 5; %rotation increment; use 5 or 10; do also use negative angles to change direction

im = double(rgb2gray(imread('UTE.png')));
im = imresize(im, 0.75);
defc = im(1, 1);
X = 10;
im(:, end : end + X) = defc; %make image more symmetric

if STARTX < 0
    im(end : end + abs(STARTX), :) = defc; %make image more symmetric
end

Sim = size(im);

xsh = 0; %starting x (A-P axis)
ysh = 0; %starting y (L-R axis)
set(gcf, 'position', [1 1 1680 954]);
for i = 0 : 360/abs(alpha)
    canvas = ones(954, 1680) * defc; %clear canvas
    projn = mean(Sim)/2 * sin(deg2rad(alpha)) / sin(deg2rad(90 - 2 * alpha));
                
    if mod(i, 2) == 0
        projn = -projn;
    end
    
    if i > 0
        xsh = xsh + projn * cos(deg2rad(alpha * i));
        ysh = ysh + projn * sin(deg2rad(alpha * i));
    end

    %correction for accumulated error at 0, 90, 270, 360 degrees
    if mod(alpha * i, 90) == 0
        xsh = 0;
        ysh = 0;
    end
    
    loc = [xsh ysh];
    fprintf('angle %d: x = %.1f, y = %.1f, procn = %.1f\n', alpha * i, xsh, ysh, projn);     
    canvas = placeimage(im, canvas, round(loc), -alpha * i);
    canvas(canvas == 0) = defc;
    Sca = size(canvas);
    canvas(Sca(1) / 2 - 1 : Sca(1) / 2 + 1, 1 : end) = 255;
    imagesc(canvas);
    pause;
end
close;

function canvas = placeimage(im, canvas, loc, angle)
% bias = -20;
bias = 0;
Sim = size(im);
Sca = size(canvas);
im = imrotate(im, angle, 'crop');
canvas(bias + round(Sca(1) / 2 - Sim(1) / 2) + loc(1) + 1 :  bias + round(Sca(1) / 2 + Sim(1) / 2) + loc(1), round(Sca(2) / 2 - Sim(2) / 2) + 1 + loc(2) : round(Sca(2) / 2 + Sim(2) / 2) + loc(2)) = im;
% canvas = imrotate(canvas, angle, 'crop');