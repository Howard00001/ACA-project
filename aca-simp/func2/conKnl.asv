function K = conKnl(D, nei)
% Construct the kernel matrix from distance.
%
% Input
%   D       -  distance matrix, n x n
%   varargin 
%     knl   -  Gaussian kernel
%     nei   -  #nearest neighbour to compute the kernel bandwidth, {.1}
%              0: binary kernel
%              NaN: set bandwidth to 1
%
% Output
%   K       -  kernel matrix, n x n
%
    % function option
%     nei = .2;
    
    sigma = bandG(D, nei);
%     sigma = 1;
    K = exp(- (D .^ 2) / (2 * sigma ^ 2 + eps));
end