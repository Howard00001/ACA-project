function nseg = reCluster(nX,ns,sel_num)
% Redo clustering for select data with fixed segment
%
% Input
%   nX : concatenated data of selected clusters
%   ns : concatenated segment points of data
%

    nK = conKnl(conDist(nX, nX));
    
    nseg = newSeg('s',ns,'G',[]);
    T = dtaksFord(nK, nseg);
    nseg.G = cluSc(T, sel_num);
end