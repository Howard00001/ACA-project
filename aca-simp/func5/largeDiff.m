function sel = largeDiff(labels, n, mode)
% select the cluster with largest difference between two videos
%
% Input
%   labels : cluster number of 2 videos(col)
%   n : cluster to choose
%   mode :  'amount' segment number difference
%           'scale' scale difference
% Output
%   sel : selected cluster's index
%
    diff = abs(labels(:,2)-labels(:,1));
    if strcmp(mode,'amount')
        [~, I] = sort(diff, 'descend');
        sel = I(1:n);
    elseif strcmp(mode,'scale')
        m = max([ones(size(labels,1),1) min(labels,[],2)],[],2);
        sc = diff./m;
        [~, I] = sort(sc, 'descend');
        sel = I(1:n);
    end
end