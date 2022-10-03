function seg = getCenter(X,K,seg,para,ends)
    % get cluster centroid index in data
    T = dtaksFord(K, seg);
    [seg.G,~,D2C] = cluSc(T, para.k);
    [~,ind] = min(D2C);
    seg.centroids=ind;
    % get cluster type by difference
    [~, ~, ~, labels] = segPart(seg.s,seg.G,ends);
    diff =  zeros(size(labels,1),1);
    for i=1:size(labels,2)/2
        diff = diff+labels(:,i*2)-labels(:,i*2-1);
    end
    seg.diff = diff;
    % get sequence data by center index
    seg.C = cell(1,size(seg.centroids,2));
    s = seg.s;
    for i=1:size(seg.centroids,2)
        cent = seg.centroids(i);
        seg.C{i} = X(:,s(cent):s(cent+1)-1);
    end
end