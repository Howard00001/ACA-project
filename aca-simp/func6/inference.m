function inference(all_paths, out_path, micename, para, paraH)
% ACA full process for data in one folder
%
% Input
%   all_path - file paths of all csv
%
    % data process
    sel = contains(all_paths, ['/',micename,'-']);
    paths=all_paths(sel);
    [X, ends, ~] = loadData(paths,para);
    
    % aca
    K = conKnl(conDist(X, X),para.kernel);
    seg = segIniR(K, para);
    if para.haca
        segResult = segHaca(K, paraH, seg);
    else
        segResult = segAca(K, para, seg);
    end

    % save ACA results
    X=[];
    K=[];
    save(strcat(out_path,strcat(micename,".mat")));
    
    % finding key motions
    if para.haca
        segResult = segResult(2);
    end
        
    fname = strcat(out_path, micename, '_cluster.png');
    [sP, LP, ~, labels] = segPart(segResult.s,segResult.G,ends);
    clusterPlot(labels,["basal" "treat"],fname);
    sel = largeDiff(labels, 2, 'treat1diff');

    BorT = ["basal" "treat"];
    for j = 1:2 
        showSegBar(sP{j}, LP{j}, [1 2 1 j], 0, sel, BorT(j));
    end
    fname = strcat(out_path, micename, '_km.png');
    saveas(gcf,fname);
    clf;
end