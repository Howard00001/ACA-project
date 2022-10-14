function [seg, segs] = segAca(K, para, seg0)
% Aligned Cluster Analysis (ACA).
% See the following paper for the details:
%   Aligned Cluster Analysis for Temporal Segmentation of Human Motion, FG 2008
%
% Input
%   K       -  frame similarity matrix, n x n
%   para    -  parameter of segmentation
%   seg0    -  inital segmentation
%
% Output
%   seg     -  segmentation result
%   segs    -  segmentation result during the procedure, 1 x nIter (cell)
%

% maximum number of iterations
    nIterMa = 100;
    
    segs = cell(1, nIterMa);
    
    for nIter = 1 : nIterMa
        % search
        segs{nIter} = dpSearch(K, para, seg0);
    
        % stop condition
        % if cluEmp(segs{nIter}.G)
        if ~isempty(find(sum(segs{nIter}.G, 2) == 0, 1))
%             prom('b', 'segAca stops due to an empty cluster\n');
            segs{nIter}.obj = inf;
            break;
        elseif isequal(segs{nIter}.G, seg0.G) && isequal(segs{nIter}.s, seg0.s)
            break;
        end
    
        seg0 = segs{nIter};
    end
    segs(nIter + 1 : end) = [];
    
    seg = segs{nIter};
end