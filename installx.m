% tic
% disp('Installing scTenifoldNet...')
% unzip('https://github.com/cailab-tamu/scTenifoldNet/archive/master.zip');
% addpath('./scTenifoldNet-master/MATLAB');
% toc

tic
disp('Installing scGEAToolbox...')
unzip('https://github.com/jamesjcai/scGEAToolbox/archive/master.zip');
addpath('./scGEAToolbox-master');
toc

if exist('cdgea.m','file')
    disp('scGEAToolbox installed!')
end