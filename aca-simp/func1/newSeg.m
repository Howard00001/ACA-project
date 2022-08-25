function seg = newSeg(varargin)
% Create segmentation structure.
%
% Input
%   nH      -  #levels
%   or
%   varargin
%     s     -  starting position, {1}
%     sH    -  starting position in hierarchy, {1}
%     G     -  class indicator, {[]}
%     acc   -  accuracy, {[]}
%     tim   -  time cost, {[]}
%     obj   -  objective value, {[]}
%
% Output
%   seg     -  seg struct
%
% History
%   create  -  Feng Zhou (zhfe99@gmail.com), 01-05-2009
%   modify  -  Feng Zhou (zhfe99@gmail.com), 01-12-2010

if nargin == 1
    nH = varargin{1};
    [s, sH, G, acc, tim, obj] = cellss(1, nH);
  
else
    s = ps(varargin, 's', 1);
    sH = ps(varargin, 'sH', 1);
    G = ps(varargin, 'G', []);
    acc = ps(varargin, 'acc', []);
    tim = ps(varargin, 'tim', []);
    obj = ps(varargin, 'obj', []);
end

seg = struct('s', s, 'sH', sH, 'G', G, 'acc', acc, 'tim', tim, 'obj', obj);
end

function value = ps(option, name, default)
% Fetch the content of the specified field within a struct or string array.
% If the field does not exist, use the default value instead.
%
% Example:
%   option.lastname = 'feng';
%   value = ps(option, 'lastname', 'noname'); % result: 'feng'
%   option = {'lastname', 'feng'};
%   value = ps(option, 'lastname', 'noname'); % result: 'feng' too
%
% Input
%   option   -  struct or string cell array
%   name     -  field name
%   default  -  default field value
%
% Output
%   value    -  the field value
%
% History
%   create  -  Feng Zhou (zhfe99@gmail.com), 02-13-2009
%   modify  -  Feng Zhou (zhfe99@gmail.com), 09-11-2009

if iscell(option)
    if isempty(option)
        option = [];
    elseif length(option) == 1
        option = option{1};
    else
        option = cell2option(option);
    end
end

if isfield(option, name)
    value = option.(name);
else
    value = default;
end
end

function option = cell2option(array)
% Convert the cell (string-value) array to a struct.
% 
% Example
%   assume   array = {'name', 'feng', 'age', 13, 'toefl', [24 25 15 26]}
%   after    option = cell2option(array)
%   then     option.name = 'feng'
%            option.age = 25
%            option.toefl = [24 25 15 26]
%
% Input
%   array   -  cell array, 1 x (2 x m) 
%
% Output
%   option  -  struct result
%
% History
%   create  -  Feng Zhou (zhfe99@gmail.com), 02-13-2009
%   modify  -  Feng Zhou (zhfe99@gmail.com), 09-11-2009

m = round(length(array) / 2);

if m == 0
    option = [];
    return;
end

for i = 1 : m
    p = i * 2 - 1;
    option.(array{p}) = array{p + 1};
end
end


