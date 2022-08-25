function [nX,nseg,splits] = selectCluster(X,seg,G,sel,ends)
% find segment and data of certain segment
%
% Input
%   X : original data
%   seg : segment
%   G : segment cluster
%   sel : cluster to select
%   ends : end point for different video
%
% Output
%   nX : new data of selected cluster
%   nseg : new segment of selected cluster
%   splits : record the last segment index of each video
%
    ind = find(sum(G(sel,:)));
    nX = [];
    nseg = 1;
    splits = [];
    ced = 1; % current end
    for i=ind
        st = seg(i);
        ed = seg(i+1);
        if st > ends(ced+1)
            ced = ced+1;
            splits = [splits size(nseg, 2)];
        end
        nX = [nX X(:,st:ed-1)];
        nseg = [nseg nseg(end)+ed-st];
    end
    splits = [splits size(nseg, 2)];
end