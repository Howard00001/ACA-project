function seg = acaBackSlow(k, sOpt, cOpt)
% Trace back to determine the segmentation.
%
% Input
%   k       -  #class
%   sOpt    -  optimum starting position, 1 x n
%   cOpt    -  optimum label, 1 x n
%
% Output
%   seg     -  segmentation
%
    % traceback
    n = length(sOpt);
    [s, l] = zeross(1, n + 1);
    
    v = n;
    m = 0;
    s(m + 1) = v + 1;
    while v > 0
        m = m + 1;
        s(m + 1) = sOpt(v);
        l(m) = cOpt(v);
    
        v = sOpt(v) - 1;
    end
    s(m + 2 : end) = [];
    s = s(m + 1 : -1 : 1);
    l(m + 1 : end) = [];
    l = l(m : -1 : 1);
    G = L2G(l, k);
    
    seg = newSeg('s', s, 'G', G);
%     seg = newSeg(s,G);
end

function seg = newSeg(s,G)
% Create segmentation structure.
%     s     -  starting position, {1}
%     sH    -  starting position in hierarchy, {1}
%     G     -  class indicator, {[]}
%     acc   -  accuracy, {[]}
%     tim   -  time cost, {[]}
%     obj   -  objective value, {[]}
%
    sH = [];
    acc = [];
    tim = [];
    obj = [];
    
    seg = struct('s', s, 'sH', sH, 'G', G, 'acc', acc, 'tim', tim, 'obj', obj);
end