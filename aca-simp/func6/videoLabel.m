function videoLabel(s, G, vid_path, save_path, sel)
% add cluster labels to video frames
%
% Input
%   s  -  segmentation
%   G  -  label
%   sel  - select certain label to show
%
    % video setting
    vid_in = VideoReader(vid_path);
    vid_out = VideoWriter(save_path);
    vid_out.FrameRate=15;
    open(vid_out);
    
    % plotted on video frames
    if sel==-1
        [markers, colors] = genMarkers;
    else
        [markers, colors] = genMarkers2(sel);
    end
    
    i=1; j=1; % frame , segment
    c = 255*colors{find(G(:, j))};
    while hasFrame(vid_in)
       frame = readFrame(vid_in);
       frame = insertText(frame,[10,10],'cluster',FontSize=20,BoxColor=c,BoxOpacity=1);
       writeVideo(vid_out,frame);
       if i > s(j+1)
           j = j+1;
           c = 255*colors{find(G(:, j))};
       end
       i = i+1;
    end
    
    close(vid_out);
%     for i = 1 : m
%         c = find(G(:, i));
% 
%         x = [s(i), s(i + 1), s(i + 1), s(i)];
%         y = [0, 0, 1, 1];
% 
%         if lnWid == 0
%             fill(x, y, colors{c}, 'EdgeColor', colors{c});
%         else
%             fill(x, y, colors{c}, 'EdgeColor', 'w', 'LineWidth', lnWid);
%         end
%     end
    
end

function [markers, colors] = genMarkers
% Generate the markers for show* functions.
% Notice that the maximum number of classes is 12.
%
% Output
%   markers  -  1 x 12 (cell)
%   colors   -  1 x 12 (cell)
%

colors = {[1 0 0], [0 0 1], [0 1 0], [1 0 1], [0 0 0], [0 1 1], [.3 .3 .3], [.5 .5 .5], [.7 .7 .7], [.1 .1 .1], [1 .8 0], [1, .4, .6]};
%             'r',     'b',     'g',     'm',     'k',     'c',  

markers = {'o', 's', '^', 'd', '+', '*', 'x', 'p', '.', 'v', 'o', 's'};
end

function [markers, colors] = genMarkers2(sel)
    colors = {[0 0 0], [0 0 0], [0 0 0], [0 0 0], [0 0 0], [0 0 0], [0 0 0], [0 0 0], [0 0 0], [0 0 0], [0 0 0], [0 0 0]};
    markers = {'o', 'o', 'o', 'o', 'o', 'o', 'o', 'o', 'o', 'o', 'o', 'o'};
    
    selcolors = {[1 0 0], [0 0 1], [0 1 0], [1 0 1], [0 0 0], [0 1 1], [.3 .3 .3], [.5 .5 .5], [.7 .7 .7], [.1 .1 .1], [1 .8 0], [1, .4, .6]};
    %             'r',     'b',     'g',     'm',     'k',     'c',  

    selmarkers = {'o', 's', '^', 'd', '+', '*', 'x', 'p', '.', 'v', 'o', 's'};
    
    for i=1:size(sel,2)
        colors{sel(i)} = selcolors{i};
        markers{sel(i)} = selmarkers{i};
    end
end
