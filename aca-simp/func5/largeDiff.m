function sel = largeDiff(labels, n, mode)
% select the cluster with largest difference between two videos
%
% Input
%   labels : cluster number of 2 videos(col)
%   n : cluster to choose
%   mode :  'amount' segment number difference
%           'scale' scale difference
%           'amount2' segment number difference each video get n//2
%           'scale2' segment number scale each video get n/2
%           'treat1' segment number scale of larger treat(second) part 
%           'treat1diff' segment number difference with larger treat(second) part
% Output
%   sel : selected cluster's index
%
    sel = 0;
    if strcmp(mode,'amount')
        diff = abs(labels(:,2)-labels(:,1));
        [~, I] = sort(diff, 'descend');
        sel = I(1:n);
    elseif strcmp(mode,'scale')
        diff = abs(labels(:,2)-labels(:,1));
        m = max([ones(size(labels,1),1) min(labels,[],2)],[],2);
        sc = diff./m;
        [~, I] = sort(sc, 'descend');
        sel = I(1:n);
    elseif strcmp(mode,'amount2')
        n=n/2;
        diff = labels(:,2)-labels(:,1);
        [~, I] = sort(diff, 'descend');
        sel = I(1:n);
        sel = [sel I(end:-1:end-n+1)];
    elseif strcmp(mode,'scale2')
        n=n/2;
        diff = labels(:,2)-labels(:,1);
        m = max([ones(size(labels,1),1) min(labels,[],2)],[],2);
        sc = diff./m;
        [~, I] = sort(sc, 'descend');
        sel = I(1:n);
        sel = [sel I(end:-1:end-n+1)];
    elseif strcmp(mode,'treat1')
        diff = labels(:,2)-labels(:,1);
        m = max([ones(size(labels,1),1) labels(:,1)],[],2);
        sc = diff./m;
        [~, I] = sort(sc, 'descend');
        sel = I(1:n);
    elseif strcmp(mode,'treat1diff')
        diff = labels(:,2)-labels(:,1);
        [~, I] = sort(diff, 'descend');
        sel = I(1:n);
    end
end