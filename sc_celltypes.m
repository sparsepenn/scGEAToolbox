function [T]=sc_celltypes(X,genelist,clusterid)

% https://academic.oup.com/database/article/doi/10.1093/database/baz046/5427041
% REF: PanglaoDB: a web server for exploration of mouse and human single-cell RNA sequencing data

oldpth=pwd;
pw1=fileparts(which(mfilename));
pth=fullfile(pw1,'thirdparty/celltype_mat');
cd(pth);
if issparse(X)
    try
        X=full(X);
    catch
        disp('Using sparse input--longer running time is expected.');
    end
end
X=sc_norm(X,"type","deseq");
genelist=upper(genelist);

Tw=readtable('markerweight.txt');
wvalu=Tw.Var2;
wgene=string(Tw.Var1);

T1=readtable('markerlist_panglaodb.txt','ReadVariableNames',false,'Delimiter','\t');
T2=readtable('markerlist_custom.txt','ReadVariableNames',false,'Delimiter','\t');
Tm=[T1;T2];
celltypev=string(Tm.Var1);
markergenev=string(Tm.Var2);
NC=max(clusterid);

S=zeros(length(celltypev),NC);

for j=1:length(celltypev)
    g=strsplit(markergenev(j),',');
    g=g(1:end-1);
    %[~,idx]=ismember(g,genelist);
    Z=zeros(NC,1); ng=zeros(NC,1);
    for i=1:length(g)
        if any(g(i)==wgene) && any(g(i)==genelist)
            wi=wvalu(g(i)==wgene);
            for k=1:NC                    
                z=mean(X(g(i)==genelist,clusterid==k));
                Z(k)=Z(k)+z*wi;
                ng(k)=ng(k)+1;
            end          
        end
    end
    for k=1:NC
        if ng(k)>0
            S(j,k)=Z(k)./nthroot(ng(k),3);
        else
            S(j,k)=0;
        end
    end
end
T=table();
% t=table(celltypev);
for k=1:NC
    [c,idx]=sort(S(:,k),'descend');
    T=[T,table(celltypev(idx),c,'VariableNames',...
        {sprintf('C%d_Cell_Type',k),sprintf('C%d_CTA_Score',k)})];
end
T=T(1:10,:);
cd(oldpth);
