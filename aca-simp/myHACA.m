%% Parameters
clear variables;
addPath;

%tempo reduction param
para.kF = 20;
para.redL = 5;
para.reduct = false;

%ACA param
para.nMi = 5;
para.nMa = 10;
para.ini='r';
para.k=8;
para.nIni=1;

%HACA param
para2 = para;
para2.nMi = 2;
para2.nMa = 6;
para2.k=8;
para2.nIni=4;
paraH = [para para2];
para.haca = true;

%output path
out_path = './output/2/';
mkdir(out_path);

%select cluster num
sel_num = 2;

%% ACA on Select data (mice) and select clusters
all_paths = getAllFile('../feat/20210811/');

nX = [];
ns = [];
splits = [];
nnames = [];

% multiple
micenames = {'B' , 'DW', 'LKB', 'LW', 'RK', 'SW', 'LKW' , 'MW', 'WT'};
for i=1:size(micenames,2)
    % data process
    micename = micenames{i};
    sel = find(contains(all_paths, ['-',micename,'-']));
    paths=all_paths(sel);
    [X, ends, names] = loadData(paths,para);
    nnames = [nnames, names];
    % aca
    K = conKnl(conDist(X, X));
    seg = segIniR(K, para);
    if para.haca
        segResult = segAca(K, para, seg);
    else
        segResult = segHAca(K, paraH, seg);
    end
    % plot result
    [sP, LP, ss, labels] = segPart(segResult.s,segResult.G,ends);
    clusterPlot(labels,names,strcat(out_path,micename,'.png'));
    % select and append 
    sel = largeDiff(labels,sel_num,'scale2');
    [cX,cs,csplits] = selectCluster(X,segResult.s,segResult.G,sel,ends);
    [nX,ns,splits] = concateSel(nX,ns,splits,cX,cs,csplits);
    
end
K=[];
save(strcat(out_path,"tmp.mat"));

%% Recluster
nseg = reCluster(nX,ns,4);
ends = [1 ns(splits(1:end-1))-1];
ends = [ends ns(end)-1];
[sP, LP, ss, labels] = segPart(nseg.s,nseg.G,ends);
clusterPlot(labels,nnames,strcat(out_path,'recluster4.png'));
clusterPlot(labels(:,1:2:end),nnames(1:2:end),strcat(out_path,'recluster4_basal.png'));
clusterPlot(labels(:,[2,4,6]),nnames([2,4,6]),strcat(out_path,'recluster4_pain.png'));
clusterPlot(labels(:,[8,10,12]),nnames([8,10,12]),strcat(out_path,'recluster4_sng.png'));
clusterPlot(labels(:,[14,16,18]),nnames([14,16,18]),strcat(out_path,'recluster4_ph74.png'));