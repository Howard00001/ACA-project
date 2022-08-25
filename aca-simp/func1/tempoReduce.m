function [sR, X, XD, XD0] = tempoReduce(X0, para)
% Remove the temporal redunancy by merging the consecutive frames with similar
% features into single frames.
%
% Input
%   X0      -  original time series, dim x n0
%   para
%     alg   -  reduction algorithm type, {'merge'} | 'ave'
%     redL  -  maximum segment length
%     kF    -  #frame cluster
%
% Output
%   sR      -  starting positions of merged areas, 1 x (m + 1)
%   X       -  reduced time series data, dim x n
%   XD      -  1-D time series after reduction, 1 x n
%   XD0     -  1-D time series before reduction, 1 x n0
%
% History
%   create  -  Feng Zhou (zhfe99@gmail.com), 01-04-2009
%   modify  -  Feng Zhou (zhfe99@gmail.com), 12-23-2009

% function option
alg = 'merge';

% prom('t', 'tempo reduce');
redL = para.redL; kF = para.kF;

% kmeans to discretize
[dim, n0] = size(X0);
if dim > 1
    G0 = kmean(X0, kF);
    XD0 = G2L(G0);
else
    XD0 = X0;
end

if strcmp(alg, 'merge')
    % insert a useless sample at the end
    XD0(n0 + 1) = -1;

    sR = ones(1, 10000);
    m = 0;
    for i = 2 : n0 + 1
        if i - sR(m + 1) >= redL || XD0(i) ~= XD0(i - 1)
            m = m + 1;
            sR(m + 1) = i;
        end
    end
    sR(m + 2 : end) = [];
    XD0(n0 + 1) = [];

elseif strcmp(alg, 'ave');
    sR = 1 : redL : n0 + 1;

else
    error('unknown alg');
end

% fetch the part
X = sPick(X0, sR);
XD = sPick(XD0, sR);
fprintf(' %d -> %d\n', n0, size(X, 2));


function [G, cost, acc] = kmean(X, k)
% K-means. A wrapper of matlab function, kmeans.
% After initalized serveral times, the one with the minimum cost is selected.
%
% Input
%   X       -  sample matrix, dim x n
%   k       -  cluster number
%   varargin
%     nRep  -  number of repetition to select the minimum cost, {50}
%     G0    -  ground truth label, k x n, {[]}
%              if indicated, adjust the output label
%
% Output
%   G       -  indicator matrix, k x n
%   cost    -  error cost
%   acc     -  accuracy if H0 is indicated
%
    nRep = 50;
    
    XTran = X';
    Gs = cell(1, nRep); 
    costs = zeros(1, nRep);
    warning off;
    for i = 1 : nRep
%         try
        L = kmeans(XTran, k, 'emptyaction', 'singleton', 'display', 'off');
%         catch
%             err = lasterror;
%             sprintf('%s\n', err.message);
%             
%             costs(i) = inf;
%             continue;
%         end
    
        G = L2G(L, k);
        
        costs(i) = evalClu(X, G);
        Gs{i} = G;
    end
    warning on;
    
    [cost, ind] = min(costs);
    G = Gs{ind};
    acc = 0;
end
end

function val = evalClu(X0, H)
% Evaluate the statstics of the given cluster.
% Several statstics are available: 
%  'in':   within-class distance
%  'out':  between-class distance
%  'all':  total distance
%
% Input
%   X0      -  sample matrix, dim x n
%   H       -  indicator matrix, k x n
%   varargin
%     type  -  statstics type, {'in'} | 'out' | 'all'
%
% Output
%   val     -  value of the specific statstic
%
    % function option
    type = 'in';
    
    k = size(H, 1);
    
    % within-class
    ins = zeros(1, k);
    for c = 1 : k
        X = cenX(X0(:, H(c, :) == 1));
        ins(c) = norm(X, 'fro');
    end
    in = ins * ins';
    
    % total
    X = cenX(X0);
    all = norm(X, 'fro');
    all = all * all;
    
    % between-class
    out = all - in;
    
    if strcmp(type, 'in')
        val = in;
    elseif strcmp(type, 'out')
        val = out;
    elseif strcmp(type, 'all')
        val = all;
    else
        error('unknown type');
    end
end

function X = cenX(X0, dire)
% Centerize the matrix to the zeros.
%
% Input
%   X0      -  original sample matrix, dim x n
%   dire    -  1 or non-indicated means the samples are stored in the columns
%           -  2 means in the rows
%
% Output
%   X       -  new sample matrix, dim x n
%
    % feature direction
    if ~exist('dire', 'var')
        dire = 1;
    end
    
    if dire == 2
        X0 = X0';
    end
    
    n = size(X0, 2);
    me = sum(X0, 2) / n;
    X = X0 - repmat(me, 1, n);
    
    if dire == 2
        X = X';
    end
end

function X = sPick(X0, s)
% Pick out the needed part of the sample matrix.
%
% Input
%   X0      -  sample matrix, dim x n0
%   s       -  starting position, 1 x (m + 1)
%
% Output
%   X       -  reduced matrix, dim x n
%
% History
%   create  -  Feng Zhou (zhfe99@gmail.com), 01-04-2009
%   modify  -  Feng Zhou (zhfe99@gmail.com), 12-23-2009

ndim = length(size(X0));

if ndim == 2
    X = X0(:, s(1 : end - 1));
    
elseif ndim == 3
    X = X0(s(1 : end - 1), :, :);
    
else
    error('unsupported');
end
end