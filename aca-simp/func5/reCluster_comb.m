function G = reCluster_comb(Xs, segResults, para)
% Redo clustering for large comobined data with fixed segment
%
    sz = 0;
    for i=1:size(Xs,2)
        segResult = segResults{i};
        for j=1:size(segResult.G,2)
            sz = sz+1; 
        end
    end
    T = zeros(sz,sz);
    ii=0; % row in T
    for i=1:size(Xs,2)
        X = Xs{i};
        segResult = segResults{i};
        s1 = segResult.s;
        for j=1:size(segResult.G,2)
            X1 = X(s1(j):s1(j+1)-1);
            wFs1 = ones(1, size(X1,2)); %frame weight 1
            ii = ii+1;
            jj = ii-1; % col in T
            for k=i:size(Xs,2)
                segResult2 = segResults{k};
                s2 = segResult2.s;
                st = 1;
                if(k==i)
                    st = j;
                end
                for l=st:size(segResult2.G,2)
                    X2 = X(s2(l):s2(l+1)-1);
                    wFs2 = ones(1, size(X2,2)); %frame weight 2
                    jj = jj+1;
                    
                    K = conKnl(conDist(X1, X2),para.kernel);
                    T(ii, jj) = dtakFord(K, 0, wFs1, wFs2);
                end
            end
        end
    end
    T = T+triu(T,1)';
    G = cluSc(T, para.k);
end