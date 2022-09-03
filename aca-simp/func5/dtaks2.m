function avg_dist = dtaks2(X1,seg1,X2,seg2,kernel)
% (Generalized) average Dynamic Time Alignment Kernel distance for two sets.
%
% Input
%   X1      -  data 1
%   X2      -  data 2
%   seg1    -  segmentation of data 1
%   seg2    -  segmentation of data 2
%
% Output
%   dist    -  average dtak distance
%
    % len(seg2) > len(seg1)
    if size(seg2,2) > size(seg1,2)
       tmpX = X2;
       X2 = X1;
       X1 = tmpX;
       tmpseg = seg2;
       seg2 = seg1;
       seg1 = tmpseg;
    end

    % similarity matrix
    K = conKnl(conDist(X1, X2),kernel);
    
    % length represent
    q = size(K, 1);  % data1 frame length
    k = size(K, 2);  % data2 frame length
    n = size(seg1,2)-1; % data1 segment length
    m = size(seg2,2)-1; % data2 segment length

    % frame weight
    wFs1 = ones(1, q);
    wFs2 = ones(1, k);

    % dtak for each pair of segment
    T = zeros(n, m);
    [P, KC] = zeross(q, k);
    for i = 1 : n
        ii = seg1(i) : seg1(i + 1) - 1;
        for j = i : m
            jj = seg2(j) : seg2(j + 1) - 1;

            [T(i, j), P(ii, jj), KC(ii, jj)] = dtakFord(K(ii, jj), 0, wFs1(ii), wFs2(jj));
        end
    end

    avg_dist = sum(T,'all')/sum(T~=0,'all');

end