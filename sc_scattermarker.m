function sc_scattermarker(X,genelist,g,s,methodid,sz)
%SC_SCATTERMARKER(X,genelist,g,s,methodid)
%
% USAGE:
% s=sc_tsne(X,3);
% g=["AGER","SFTPC","SCGB3A2","TPPP3"];
% sc_scattermarker(X,genelist,g,s);

if isvector(s)||isscalar(s), error('S should be a matrix.'); end
if nargin<6, sz=5; end
if nargin<5, methodid=1; end
if iscell(g)
    for k=1:length(g)
        figure;
        sc_scattermarker(X,genelist,g{k},s,methodid,sz);
    end
elseif isstring(g) && ~isStringScalar(g)
    for k=1:length(g)
        figure;
        sc_scattermarker(X,genelist,g(k),s,methodid,sz);
    end
elseif isStringScalar(g) || ischar(g)
    if ismember(g,genelist)
        x=s(:,1);
        y=s(:,2);
        if min(size(s))==2
            z=[];
        else
            z=s(:,3);
        end               
        switch methodid
            case 1
                z=log2(1+X(genelist==g,:));
                sc_stemscatter(x,y,z);
            case 2                
                c=log2(1+X(genelist==g,:));
                if isempty(z)
                    scatter(x,y,sz,c,'filled');
                else
                    scatter3(x,y,z,sz,c,'filled');
                end
                colormap('default');
            case 3                
                c=log2(1+X(genelist==g,:));
                if isempty(z)
                    scatter(x,y,sz,c,'filled');
                else
                    scatter3(x,y,z,sz,c,'filled');
                end                
                a=colormap('autumn');
                a(1,:)=[.8 .8 .8];
                colormap(a);
            case 4
               subplot(1,2,1)
               sc_scattermarker(X,genelist,g,s,3,sz);
               subplot(1,2,2)
               sc_scattermarker(X,genelist,g,s,1,sz);
               hFig=gcf;
               hFig.Position(3)=hFig.Position(3)*2;
            case 5
               if size(s,2)>=3
                   x=s(:,1); y=s(:,2); z=s(:,3);
               else
                   x=s(:,1); y=s(:,2); z=zeros(size(x));
               end
               explorer2IDX=y;
               assignin('base','explorer2IDX',explorer2IDX);
               c=log2(1+X(genelist==g,:));
               
               h1=subplot(1,2,1); 
                scatter3(x,y,z,sz,c,'filled');
                a=colormap('autumn');
                a(1,:)=[.8 .8 .8];
                colormap(a);
                % h1.YDataSource='explorer2IDX';
                title(g)
               subplot(1,2,2)                
                stem3(x,y,c,'marker','none','color','m');
                hold on
                scatter3(x,y,zeros(size(y)),5,c,'filled');                
                % h2.YDataSource='explorer2IDX';
                % hLD = linkdata('on');
                evalin('base','h=findobj(gcf,''type'',''axes'');');
                evalin('base','hlink = linkprop(h,{''CameraPosition'',''CameraUpVector''});');
                evalin('base','rotate3d on');                
                hFig=gcf;
                hFig.Position(3)=hFig.Position(3)*2;
                view(h1,3);
        end
        title(g)
    else
        warning('%s no expression',g);
    end
end
