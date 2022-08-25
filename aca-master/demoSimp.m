clear variables;

tag = 10; 

%% source
wsSrc = mocSegSrc(tag);
[para, paraH] = stFld(wsSrc, 'para', 'paraH');
para.nMi = 10;
para.nMa = 20;
para.ini='r';
para.k=10;
%% feature
% load('X.mat');
% load('segT.mat');
segT = [];
%
% load('raw_test.mat');X =X0;
% X = table2array(readtable('feat.csv'))';
X0 = table2array(readtable('../feat/20210811/Cap-B-basal.csv'))';X1 = table2array(readtable('../feat/20210811/Cap-B-treat.csv'))';X = [X0 X1];
% load('pose_label.mat');X = label';
%
K = conKnl(conDist(X, X), 'nei', .02);
para.nIni = 1;

%% init
seg0s = segIni(K, para);

%% aca
[segAca, segAcas] = segAlg('aca', [], K, para, seg0s, segT);
seg = segAca.s;
label = segAca.G;

%% haca
% seg0s = segIni(K, paraH(1));
% segHaca = segAlg('haca', [], K, paraH, seg0s, segT);

%% plot
figure;
showM(K, 'fig', [1 1 2 1]);
title('Kernel matrix (K)');
showSeq(X, 'fig', [1 1 2 2]);
title('feature in 2-D space');
figure;
showSegBar(segAca, 'fig', [1 1 1 1], 'mkSiz', 0, 'lnWid', 1);
title(sprintf('aca accuracy %.2f', segAca.acc));


%% statistic
split = find(seg>=size(X0,2), 1)-1;
labels = [sum(label(:,1:split),2) sum(label(:,split+1:end),2)];
figure;
bar(labels);
legend({'basal','treat'});
title('health pain result');
xlabel('cluster');
ylabel('segments');