clear variables;
addPath;

%tempo reduction param
para.kF = 20;
para.redL = 5;
para.reduct = false;

%ACA param
para.nMi = 10;
para.nMa = 20;
para.ini='r';
para.k=8;
para.nIni=1;

%HACA param
para2 = para;
para2.nMi = 4;
para2.nMa = 8;
para2.k=4;
para2.nIni=10;
paraH = [para para2];

%output path
out_path = './output/';
%mkdir(out_path);

%select cluster num
sel_num = 2;

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
    segResult = segAca(K, para, seg);
    % plot result
    [sP, LP, ss, labels] = segPart(segResult.s,segResult.G,ends);
    clusterPlot(labels,names,strcat(out_path,micename,'.png'));
    % select and append 
    sel = largeDiff(labels,sel_num,'scale2');
    [cX,cs,csplits] = selectCluster(X,segResult.s,segResult.G,sel,ends);
    [nX,ns,splits] = concateSel(nX,ns,splits,cX,cs,csplits);
    
end
save("tmp.mat");

nseg = reCluster(nX,ns,sel_num);
ends = ns(splits(1:end-1));
[sP, LP, ss, labels] = segPart(nseg.s,nseg.G,ends);
clusterPlot(labels,nnames,strcat(out_path,'recluster.png'));