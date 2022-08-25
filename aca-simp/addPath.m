function addPath
% Add folders of predefined functions into matlab searching paths.

global footpath;
footpath = cd;

addpath(genpath([footpath '/func1']));
addpath(genpath([footpath '/func2']));
addpath(genpath([footpath '/func3']));
addpath(genpath([footpath '/func4']));
addpath(genpath([footpath '/func5']));

% random seed generation
rand('twister', sum(100 * clock));
