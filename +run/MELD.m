function [sample_likelihoods,T]=MELD(X,batchid,usematinput,useh5)
% MELD - a graph signal processing tool used to smooth a binary variable on 
% the cell-cell graph to determine which regions of its underlying 
% data manifold are enriched or depleted in cells with a specific 
% feature.
isdebug=true;
if nargin<4, useh5=false; end
if nargin<3, usematinput=true; end
if nargin<2
    %batchid=string([true(ceil(size(X,2)/2),1); false(floor(size(X,2)/2),1)]);
    error('USAGE: score=run.MELD(X,batchid)');
end
oldpth=pwd();
pw1=fileparts(mfilename('fullpath'));
wrkpth=fullfile(pw1,'thirdparty','py_MELD');
cd(wrkpth);
if ~isdebug
if exist('./batchid.txt','file'), delete('./batchid.txt'); end
if exist('./input.txt','file'), delete('./input.txt'); end
if exist('./output.txt','file'), delete('./output.txt'); end
if exist('./input.mat','file'), delete('./input.mat'); end
end

X=sc_norm(X);
X=sqrt(X);

if usematinput
    if ~useh5
        save('input.mat','X','batchid','-v7');
    else
        save('input.mat','X','batchid','-v7.3');
    end
else
    writematrix(X,'input.txt');
    writematrix(batchid,'batchid.txt');
end

x=pyenv;
pkg.i_add_conda_python_path;
if usematinput
    if ~useh5
        cmdlinestr=sprintf('"%s" "%s%sscript_v7.py"',x.Executable,wrkpth,filesep);
    else
        cmdlinestr=sprintf('"%s" "%s%sscript_h5.py"',x.Executable,wrkpth,filesep);
    end
else
    cmdlinestr=sprintf('"%s" "%s%sscript_csv.py"',x.Executable,wrkpth,filesep);
end
disp(cmdlinestr)
[status]=system(cmdlinestr);

sample_likelihoods=[];
if status==0 && exist('output.txt','file')
    warning off
    T=readtable('output.txt',"ReadVariableNames",true);
    warning on
    sample_likelihoods=table2array(T);
end

if ~isdebug
if exist('./batchid.txt','file'), delete('./batchid.txt'); end
if exist('./input.txt','file'), delete('./input.txt'); end
if exist('./output.txt','file'), delete('./output.txt'); end
if exist('./input.mat','file'), delete('./input.mat'); end
end
cd(oldpth);
end
