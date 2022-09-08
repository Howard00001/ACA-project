function showSegBar(s, G, fig, lnWid, sel, title_name)
% Show segmentation of one sequence. The segments would be displayed as rectangulars.
%
% Input
%   seg  -  segmentation
%   fig  -  subfigure setting
%   lnWid  -  line width
%   sel  - selection
%
    % show option
    figure(fig(1));
    subplot(fig(2), fig(3), fig(4), 'replace');
    title(title_name);

    % function option
%     lnWid = 1;

    % plotted segment
    % ss = seg.s; G = seg.G;
    [k, m] = size(G);
    cs = 1 : k; 
    visC = zeros(1, k); %idx2vis(cs, k);
    visC(cs) = 1;
    ms = 1 : m; 
    visM = zeros(1, k); %idx2vis(ms, m);
    visM(ms) = 1;

    hold on;
    if ~exist('sel','var')
        [markers, colors] = genMarkers;
    else
        [markers, colors] = genMarkers2(sel);
    end
    
    for i = 1 : m
        c = find(G(:, i));

        % skip the segments
        if ~visC(c) || ~visM(i)
            continue;
        end

        x = [s(i), s(i + 1), s(i + 1), s(i)];
        y = [0, 0, 1, 1];

        if lnWid == 0
            fill(x, y, colors{c}, 'EdgeColor', colors{c});
        else
            fill(x, y, colors{c}, 'EdgeColor', 'w', 'LineWidth', lnWid);
        end
    end
    
    axis off;
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
