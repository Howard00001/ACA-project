function showSegBar(seg, fig, lnWid)
% Show segmentation of one sequence. The segments would be displayed as rectangulars.
%
% Input
%   seg      -  segmentation
%
%
    % show option
    figure(fig(1));
    subplot(fig(2), fig(3), fig(4), 'replace');

    % function option
%     lnWid = 1;

    % plotted segment
    s = seg.s; G = seg.G;
    [k, m] = size(G);
    cs = 1 : k; 
    visC = zeros(1, k); %idx2vis(cs, k);
    visC(cs) = 1;
    ms = 1 : m; 
    visM = zeros(1, k); %idx2vis(ms, m);
    visM(ms) = 1;

    hold on;
    [markers, colors] = genMarkers;
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
% History
%   create   -  Feng Zhou (zhfe99@gmail.com), 01-03-2009
%   modify   -  Feng Zhou (zhfe99@gmail.com), 12-17-2009

colors = {[1 0 0], [0 0 1], [0 1 0], [1 0 1], [0 0 0], [0 1 1], [.3 .3 .3], [.5 .5 .5], [.7 .7 .7], [.1 .1 .1], [1 .8 0], [1, .4, .6]};
%             'r',     'b',     'g',     'm',     'k',     'c',  

markers = {'o', 's', '^', 'd', '+', '*', 'x', 'p', '.', 'v', 'o', 's'};
end