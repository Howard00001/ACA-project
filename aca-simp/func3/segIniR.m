function seg = segIniR(K, para)
% Randomly initialize the segmentation.
%
% Input
%   K       -  frame similarity, n x n
%   para    -  segmentation parameter
%
% Output
%   seg     -  temporal segmentation result
%
    n = size(K, 1);
    k=para.k;
    nMi=para.nMi;
    nMa=para.nMa;
    
    % generate segmentation until the constraints have been satisfied
    co = 0;
    while true
        co = co + 1;
        % randomly generate segment position
        s = ones(1, n + 1);
        head = 1;
        m = 0;
        while head <= n
            m = m + 1;
            s(m) = head;
    
            len = float2block(rand(1), nMi, nMa);
            head = head + len;
        end
        s(m + 1) = n + 1;
        s(m + 2 : end) = [];
        
        % ensure that each segment has satisfied the length constraint
        ns = diff(s);
        visMi = ns < nMi;
        visMa = ns > nMa;
        if any(visMi | visMa)
            continue;
        end
    
        % label by clustering
        seg = newSeg('s',s,'G',[]);
        T = dtaksFord(K, seg);
        seg.G = cluSc(T, k);
        
        % ensure that each cluster has at least one segment
        %if ~cluEmp(seg.G)
        if isempty(find(sum(seg.G, 2) == 0, 1))
            break;
        elseif co > 100
            fprintf('empty cluster\n');
        end
    end
end