function [nX,ns,splits] = concateSel(X1,s1,splits1,X2,s2,splits2)
% concatenate data and segment, tune the segment index 
%
    nX = [X1 X2];
    
    xed = size(X1,2);
    ns = [s1 s2+xed];
    
    sed = size(s1,2);
    splits = [splits1 splits2+sed];
end