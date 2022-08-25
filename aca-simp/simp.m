clear variables;

%tempo reduction param
para.kF = 20;
para.redL = 5;

%ACA param
para.nMi = 5;
para.nMa = 10;
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


% data
X = table2array(readtable('../feat/20210811/Cap-B-basal.csv'))';%X1 = table2array(readtable('../feat/20210811/Cap-B-treat.csv'))';X = [X0 X1];
[~, X, ~, ~] = tempoReduce(X, para);
K = conKnl(conDist(X, X));
seg = segIniR(K, para);

% ACA
segResult = segAca(K, para, seg);

% HACA
% segHResult = segHaca(K,paraH,seg);
