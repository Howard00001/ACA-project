function seg = dpSearch(K, para, seg0)
% Search for the optimal segementation via dynamic programming.
%
% Input
%   K       -  frame similarity matrix, n x n
%   para    -  parameter of segmentation
%     lc    -  local constraint (Sakoe and Chiba)
%              0 : not used
%              1 : used
%     wFs   -  frame weights, {[]}
%   seg0    -  inital segmentation
%
% Output
%   seg     -  segmentation
%
    n = size(K, 1);
    
    % local constarint
    lc = 0;
    
    % frame weights
    wFs = ones(1, n);
    
    % pairwise DTAK
    T = dtaksFord(K, seg0);
    
    % forward
    [sOpt, cOpt, objOpt] = acaFord(K, para, seg0, T, lc, wFs);
    
    % backward
    seg = acaBack(para.k, sOpt, cOpt);
    
    % objective value
    seg.obj = objOpt(end);
end