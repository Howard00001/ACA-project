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
    for i=1:size(ends,2)
        ed = find(seg>=ends(i)+1,1);
        sP{i} = seg(:,st:ed);
        LP{i} = label(:,st2:ed-1);
        if seg(ed)==ends(i)
            st = ed;
            st2 = ed;
        else
            st = ed-1;
            st2 = ed-1;
        end
    end
    
    
    ss = {};
    labels = [];
    %i==1
    sseg = sP{1};
    ss{1} = sseg;
    label = LP{1};
    labels = [labels sum(label,2)];
    for i=2:size(LP,2)
        sseg = sP{i};
        sseg = sseg - ends(i-1);
        sseg(1)=1;
        sseg(end) = ends(i)-ends(i-1)+1;
        ss{i} = sseg;
        label = LP{i};
        labels = [labels sum(label,2)];
    end
end