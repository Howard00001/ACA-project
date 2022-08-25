function [T, P, KC, ws] = dtaksFord(K, seg)
% (Generalized) Dynamic Time Alignment Kernel with segmentation.
%
% Input
%   K       -  kernel matrix, n x n
%   seg     -  segmentation
%   lc      -  local constraint (Sakoe and Chiba)
%              0 : not used
%              1 : used
%   wFs     -  frame weight, 1 x n
%              []: weight as 1
%
% Output
%   T       -  segment kernel matrix, m x m
%   P       -  path matrix, n x n
%   KC      -  cumulative kernel matrix, n x n
%   ws      -  segment weight, 1 x m
%
    n = size(K, 1);
    
    % local constraint
    lc = 0;
    % frame weight
    wFs = ones(1, n);
    
    s = seg.s;
    m = length(s) - 1;
    ws = zeros(1, m);
    for i = 1 : m
        ws(i) = sum(wFs(s(i) : s(i + 1) - 1));
    end
    
    % dtak for each pair of segment
    T = zeros(m, m);
    [P, KC] = zeross(n, n);
    for i = 1 : m
        ii = s(i) : s(i + 1) - 1;
        for j = i : m
            jj = s(j) : s(j + 1) - 1;
    
            [T(i, j), P(ii, jj), KC(ii, jj)] = dtakFord(K(ii, jj), lc, wFs(ii), wFs(jj));
        end
    end
    T = T + triu(T, 1)';
end