function [nX,nseg] = selectCluster(X,seg,G,sel)
% find segment and data of certain segment
%
% Input
%   X : original data
%   seg : segment
%   G : segment cluster
%   sel : cluster to select
%
% Output
%   nX : new data of selected cluster
%   nseg : new segment of selected cluster
%
    ind = find(sum(G(sel,:)));
    nX = [];
    nseg = 1;
    for i=ind
        st = seg(i);
        ed = seg(i+1);
        nX = [nX X(:,st:ed-1)];
        nseg = [nseg nseg(end)+ed-st];
    end
end