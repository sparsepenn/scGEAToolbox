function  [XM]=i_nc(X,nsubsmpl,ncom,csubsmpl,usebootstrp)
% NC - network construction
%
% input: X -  n (genes/features) x m (cells/samples) matrix
% output XM - k multi-layer network array (n x n x k)
import ten.*

if nargin<5, usebootstrp=true; end  % using m-out-of-n bootstrap (false by default)
                                     % using jackknife (by default)
if nargin<4, csubsmpl=500; end       % number of cells in subsamples                                     
if nargin<3, ncom=3; end             % number of components for PC regression
if nargin<2, nsubsmpl=10; end        % number of subsamples 

    n=size(X,1);
    XM=zeros(n,n,nsubsmpl);
    for k=1:nsubsmpl
        fprintf('Building network...%d of %d\n',k,nsubsmpl);
        
        n0=size(X,2);
        if n0<csubsmpl*1.15
            usebootstrp=true;
        end
        if usebootstrp % bootstrap 
            i=randi(n0,1,csubsmpl);
            Xrep=X(:,i);
        else           % jackknife
            Xrep=X(:,randperm(n0));
            Xrep=Xrep(:,1:csubsmpl);
        end
        A=sc_pcnetpar(Xrep,ncom,true);

%         tstr=matlab.lang.makeValidName(datestr(datetime));
%         save(sprintf('A_%s',tstr),'A','-v7.3');
        
        XM(:,:,k)=ten.e_filtadjc(A,0.90,false);
        %a=max(abs(A(:)));
        %XM(:,:,k)=A./a;
    end
end
