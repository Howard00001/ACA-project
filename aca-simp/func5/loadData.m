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
    culmu = 0;
    for i=1:sz
        tmp = table2array(readtable(paths{i}))';
        if para.reduct
            [~, tmp, ~, ~] = tempoReduce(tmp, para);  %temporal reduction
        end
        if para.split > 0
            sel =round(size(tmp,2)*para.split);
            tmp = tmp(:,1:sel);
        end
        if para.split < 0
            sel =round(size(tmp,2)*-para.split);
            tmp = tmp(:,sel:end);
        end
        culmu = culmu+size(tmp,2);
        ends = [ends culmu];
        X = [X tmp];
        
        % get name
        sp = split(paths{i},'/');
        sp = split(sp{end},'.c');
        names{i} = sp{1};
    end
    %ends = [ends size(X,2)];
end