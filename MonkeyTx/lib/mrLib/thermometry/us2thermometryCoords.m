function ptMr = us2thermometryCoords(sys,pt)
[~,usIdx(1)] = min(abs(sys.ux-pt(1)));
[~,usIdx(2)] = min(abs(sys.uy-pt(2)));
[~,usIdx(3)] = min(abs(sys.uz-pt(3)));

ptMr(1) = sys.ax(usIdx(1));
ptMr(2) = sys.ay(usIdx(2));
ptMr(3) = sys.az(usIdx(3));

