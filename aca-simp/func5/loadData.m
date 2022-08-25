function [X, ends, names] = loadData(paths, para)
% Load dataset and concatenate for ACA
% 
% Input
%   paths : csv paths of dataset to be concatenated
%   para : ACA parameter for temporal reduction
%
% Output
%   X : concatenated data
%   ends : end index of each video
%   names : names of different data
% 
    sz = size(paths,2);
    X = [];
    ends = [];
    names = {};
    for i=1:sz
        tmp = table2array(readtable(paths{i}))';
        if para.reduct
            [~, tmp, ~, ~] = tempoReduce(tmp, para);  %temporal reduction
        end
        ends = [ends size(X,2)];
        X = [X tmp];
        
        % get name
        sp = split(paths{i},'/');
        sp = split(sp{end},'.c');
        names{i} = sp{1};
    end
    ends = [ends size(X,2)];
end