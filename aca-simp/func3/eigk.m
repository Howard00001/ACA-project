function [V, d] = eigk(A, k)
% Find the leading k eigenvectors.
%
% Input
%   A       -  input matrix, n x n
%   k       -  number of eigenvectors
%
% Output
%   V       -  eigenvectors, n x k
%   d       -  eigenvalues, k x 1
%
    opt.disp = 0;
    [V, D] = eigs(A, k, 'lm', opt);
    
    d = diag(D);
    [d, ind] = sort(d, 'descend');
    V = V(:, ind);
end