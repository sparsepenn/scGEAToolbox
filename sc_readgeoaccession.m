function [sce]=sc_readgeoaccession(acc)

if length(strsplit(acc,{',',';',' '}))>1
    
end
url=sprintf('https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=%s',acc);
a=webread(url);
b=strsplit(a,'\n');
c=string(b(contains(b,acc)))';
c=c(contains(c,'ftp'));
if length(c)~=3 && length(c)~=1
    disp(url)
    error('Unknown error.');
end

switch length(c)
    case 3
        c1=c(contains(c,'mtx'));
        if isempty(c1), error('MTX file not found.'); end
        f1=i_setupfile(c1);
        if isempty(f1), error('MTX file name not processed.'); end
        
        c2=c(contains(c,'genes'));
        if isempty(c2), c2=c(contains(c,'features')); end
        if isempty(c2), error('GENES/FEATURES file not found.'); end
        f2=i_setupfile(c2);
        if isempty(f2), error('GENES/FEATURES file name not processed.'); end
        [X,g]=sc_readmtxfile(f1,f2);
    case 1
        txtnotfound=false;
        c1=c(contains(c,'txt'));
        if isempty(c1)
            c1=c(contains(c,'csv'));
            if isempty(c1)
                c1=c(contains(c,'tsv'));
                if isempty(c1)
                    txtnotfound=true;
                    % error('TXT/CSV/TSV file not found.');
                end
            end
        end
        if ~txtnotfound
            f1=i_setupfile(c1);
            if isempty(f1), error('TXT/CSV/TSV file name not processed.'); end
            [X,g]=sc_readtsvfile(f1);
        else   
            c1=c(contains(c,'h5'));
            if isempty(c1)
                error('File not found.');
            end
            f1=i_setupfile2(c1);
            [X,g]=sc_readhdf5file(f1);
        end
        
end
sce=SingleCellExperiment(X,g);


% function i_tryh5(c)
%     c1=c(contains(c,'tsv'));
% end

end

function f=i_setupfile(c)    
    try
        tmpd=tempdir;
        [x]=regexp(c(1),'<a href="ftp://(.*)">(ftp','match');
        x=string(textscan(x,'<a href="ftp://%s'));
        x=append("https://", extractBefore(x,strlength(x)-5));
        x=urldecode(x);
        fprintf('Downloading %s\n',x)
        files=gunzip(x,tmpd);
        f=files{1};
    catch
        f=[];
    end
end

function f=i_setupfile2(c)    
    try
        tmpd=tempname;
        [x]=regexp(c(1),'<a href="ftp://(.*)">(ftp','match');
        x=string(textscan(x,'<a href="ftp://%s'));
        x=append("https://", extractBefore(x,strlength(x)-5));
        x=urldecode(x);
        fprintf('Downloading %s\n',x)
        f=websave(tmpd,x);        
    catch
        f=[];
    end
end
