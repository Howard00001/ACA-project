function seg0s = segIni(K, para)
% Initalize the segmentation.
%
% Input
%   K       -  frame similarity matrix, n x n
%   para    -  segmentation parameter
%     ini   -  initialization method, 'r' | 'p'
%              'r': rand segmentation
%              'p': propagative segmentation
%              'g': gmm
%     nIni  -  #initialization
%   varargin
%     segT  -  ground-truth segmentation, {[]}
%
% Output
%   seg0    -  initial segmentations, 1 x nIni (cell)
%   inis    -  initialization method, 1 x nIni (cell)
%   para    -  copy from the input
%   
    ini = para.ini; nIni = para.nIni;
    [seg0s, inis] = cellss(1, nIni);
    
    for i = 1 : nIni
        if strcmp(ini, 'r')
            seg0s{i} = segIniR(K, para);
            inis{i} = 'r';
        else
            error('unknown method');
        end
    end
end
