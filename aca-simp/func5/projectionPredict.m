function seg = projectionPredict(X, seg, C, para)
    s = seg.s;
    seg.G = zeros(size(seg.G));
    for i=1:size(seg.G,2)
       T = zeros(1,size(seg.G,1));
       for j=1:size(seg.G,1)
           X1 = X(:,s(i):s(i+1)-1);
           X2 = C{j};
           wFs1 = ones(1, size(X1,2));
           wFs2 = ones(1, size(X2,2));
           K = conKnl(conDist(X1, X2),para.kernel);
           T(j) = dtakFord(K, 0, wFs1, wFs2);
       end
       [~,ind] = min(T);
       seg.G(ind,i) = 1;
    end
end