function [dc,T]=Revelio(X,genelist)
%Run Revelio
%
% see also: 
% https://github.com/danielschw188/Revelio

isdebug=false;
oldpth=pwd();
[isok,msg]=commoncheck_R('R_Revelio');
if ~isok, error(msg); return; end

if isa(X,'SingleCellExperiment')
    genelist=upper(X.g);
    X=X.X;
end
if ~iscellstr(genelist) && isstring(genelist)
    genelist=cellstr(upper(genelist));
end



if ~isdebug
    if exist('./input.mat','file'), delete('./input.mat'); end
    if exist('./output.mat','file'), delete('./output.mat'); end
    if exist('./output.csv','file'), delete('./output.csv'); end
end
save('input.mat','X','genelist','-v6');
pkg.RunRcode('script.R');
if exist('./output.mat','file')
    load('output.mat','dc');
    dc=transpose(dc);
end
if exist('./output.csv','file')
    T=readtable('./output.csv','ReadVariableNames',false);
    T=addvars(T,str2double(extractAfter(string(T.Var2),1)));
end
if ~isdebug
    if exist('./input.mat','file'), delete('./input.mat'); end
    if exist('./output.mat','file'), delete('./output.mat'); end
    if exist('./output.csv','file'), delete('./output.csv'); end
end
cd(oldpth);
%figure;
%gscatter(dc(:,1),dc(:,2),T.Var1)
end
