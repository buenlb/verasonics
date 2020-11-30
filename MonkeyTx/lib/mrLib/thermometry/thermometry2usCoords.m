function ptUs = thermometry2usCoords(sys,pt)
[~,mrIdx(1)] = min(abs(sys.ax-pt(1)));
[~,mrIdx(2)] = min(abs(sys.ay-pt(2)));
[~,mrIdx(3)] = min(abs(sys.az-pt(3)));

ptUs(1) = sys.ux(mrIdx(1));
ptUs(2) = sys.uy(mrIdx(2));
ptUs(3) = sys.uz(mrIdx(3));