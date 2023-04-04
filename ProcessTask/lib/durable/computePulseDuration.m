function pd = computePulseDuration(sessions)
prf = [sessions.PRF];
dc = [sessions.dc]*1e-2;
% nFoci = [sessions.nFoci];
% nFoci(nFoci==0) = 1;

pd = dc./prf;


