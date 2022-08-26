function [sP, LP, ss, labels] = segPart(seg,label,ends)
% Split the aca result by different video (ex : health, pain)
%
% Input
%   seg : ACA result segment
%   label : ACA result label
%   ends : split point of different video
%
% Output
%   sP : segments partitions
%   LP : labels partitions
%   ss : segment points of each videos
%   labels : cluster statistic
%
    sP = {};
    LP = {};
    st = 1;
    st2 = 1;
    for i=1:size(ends,2)-1
        ed = find(seg>=ends(i+1)+1,1);
        sP{i} = seg(:,st:ed);
        LP{i} = label(:,st2:ed-1);
        if seg(ed)==ends(i+1)
            st = ed;
            st2 = ed;
        else
            st = ed-1;
            st2 = ed-1;
        end
    end
    
    ss = {};
    labels = [];
    for i=1:size(LP,2)
        sseg = sP{i};
        sseg = sseg - ends(i);
        sseg(1)=1;
        sseg(end) = ends(i+1)-ends(i)+1;
        ss{i} = sseg;
        label = LP{i};
        labels = [labels sum(label,2)];
    end
end