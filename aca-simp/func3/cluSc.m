function [H, Y, D2C] = cluSc(S, k)
% Spectral Clustering.
%
% Input
%   S       -  similarity matrix, n x n
%   k       -  cluster number
%
% Output
%   H       -  indicator matrix, k x n
%   Y       -  sample matrix after embedding, k x n
%
    De = diag(sum(S, 2));
    De2 = sqrt(De);
    L = De2 \ S / De2;
    
    X = eigk(L, k);
    Y = X';
    
    % normalize rows of X
    tmp = sqrt(sum(X .^ 2, 2));
    for i = 1 : length(tmp)
        if abs(tmp(i)) < eps
            tmp(i) = 1;
        end
    end
    X = diag(tmp) \ X;
    
    % k-means
    [H,~,~,D2C] = kmean(X', k);
end