function clusterPlot(labels,names,fname)
% Plot amount of each cluster for different videos and save to file
%
% Input
%   labels : cluster statistic
%   names : lengend name for each video
%   fname : saving figure path + file name
%
%     figure;
    bar(labels);
    legend(names,'location','eastoutside');
    title('result');
    xlabel('cluster');
    ylabel('segments');
    
    % save figure
    if size(fname,2)>0
        saveas(gcf,fname);
        clf;
    end
end