T=readtable('PanglaoDB_markers_27_Mar_2020.tsv','filetype','text');
sp="Mm"; 
%sp="Hs";

i=contains(string(T.species),sp);
T=T(i,:);

a=string(unique(T.cellType));
gt=string(T.cellType);
to=string(T.officialGeneSymbol);
fid=fopen(sprintf('markerlist_%s_panglaodb.txt',lower(sp)),'w');
for k=1:length(a)
    k
    idx=find(gt==a(k));
    fprintf(fid,'%s\t',a(k));
    fprintf(fid,'%s,', to(idx));
    fprintf(fid,'\n');
end
fclose(fid);
