function callback_MarkerGeneHeatmap(src,~)

    FigureHandle=src.Parent.Parent;
    sce=guidata(FigureHandle);
    if isempty(sce.c_cell_type_tx)
        errordlg('sce.c_cell_type_tx is empty');
        return;
    end
    [c,cL]=grp2idx(sce.c_cell_type_tx);
    if numel(cL)==1
        helpdlg('Only one cell type')
        return; 
    end

    fw=pkg.gui_waitbar;
    M=cell(numel(cL),2);
    for k=1:numel(cL)
        [markerlist]=sc_pickmarkers(sce.X,sce.g,c,k);
        cLk=matlab.lang.makeValidName(cL{k});
        M{k,1}=cLk;
        M{k,2}=markerlist;
    end
    pkg.gui_waitbar(fw);    
    
% ==============    
    
    
    X=[]; szcl=[]; idcl=[];
    for k=1:length(cL)
        i=c==k;
        X=[X sce.X(:,i)];
        szcl=[szcl sum(i)];
        idcl=[idcl; c(i)];
    end
    X=sc_norm(X);
    X=log2(X+1);

% =========== 
Y=[]; idgn=[]; szgn=[];
% subi=1:10:size(X,2);
MX=[];
for k=1:numel(cL)
    markerlist=M{k,2}(1:10);
    MX=[MX; markerlist];
    % cLk=M{k,1};
    [~,idx_g]=ismember(upper(markerlist),upper(sce.g));
    Y=[Y; X(idx_g,:)];
    idgn=[idgn; k*ones(length(markerlist),1)];
    szgn=[szgn length(markerlist)];
end


    Y=zscore(Y,0,2);
    qx=quantile(Y(:),0.90);
    Y(Y>qx)=qx;
    qx=quantile(Y(:),0.10);
    Y(Y<qx)=qx;
    
figure;
imagesc(Y);
szc=cumsum(szgn);
for k=1:max(idcl)-1
    xline(sum(idcl<k+1)+0.5,'r-');
    yline(szc(k)+0.5,'r-');
end
set(gca,'YTick',1:size(Y,1));
a=[]; b=[];
for k=1:max(idcl)
    a=[a sum(idcl<=k)];
    b=[b round(sum(idcl==k)./2)];
end
set(gca,'XTick',a-b);
set(gca,'XTickLabel',M(:,1));
set(gca,'XTickLabelRotation',315);
set(gca,'YTickLabel',MX);
set(gca,'TickLength',[0 0])
pause(3)
        labels = {'Save marker gene map M to variable named:'}; 
        vars = {'M'};
        values = {M};
        export2wsdlg(labels,vars,values);

end

%{
    FigureHandle=gcf;
    hAx = axes('Parent',FigureHandle);
    UitoolbarHandle = uitoolbar('Parent',FigureHandle ) ; 
    pt3 = uipushtool(UitoolbarHandle,'Separator','off');
    pt3.Tooltip = 'Select a gene to show expression';
    [img,map] = imread(fullfile(matlabroot,...
                'toolbox','matlab','icons','greencircleicon.gif'));
    ptImage = ind2rgb(img,map);
    pt3.CData = ptImage;
    pt3.ClickedCallback = {@i_saveM,M};

    function i_saveM(~,~,M)    
        labels = {'Save marker gene map M to variable named:'}; 
        vars = {'M'};
        values = {M};
        export2wsdlg(labels,vars,values);
    end
%}

%{    
    
    FigureHandle=figure;
    hAx = axes('Parent',FigureHandle);
    UitoolbarHandle = uitoolbar( 'Parent', FigureHandle ) ; 
    pt3 = uipushtool(UitoolbarHandle,'Separator','off');
    pt3.Tooltip = 'Select a gene to show expression';
    
    cLk=matlab.lang.makeValidName(cL{k});
    pt3.ClickedCallback = {@callback_PickMarkerGene,...
        markerlist,cLk};
[img,map] = imread(fullfile(matlabroot,...
            'toolbox','matlab','icons','greencircleicon.gif'));
ptImage = ind2rgb(img,map);

pt3.CData = ptImage;
    
    xxx=zscore(xx,0,2);
    qx=quantile(xxx(:),0.90);
    xxx(xxx>qx)=qx;

    %qx=quantile(xx(:),0.95);
    %xx(xx>qx)=qx;
%{    
xxk=xx;
try
for ix=1:size(xx,2)
    thisc=xx(ix,:);    
    [~,thisidx]=sort(thisc);
    thisa=ksdensity(thisc,"NumPoints",size(xx,2));
    thisc(thisidx)=thisa;
    xxk(ix,:)=thisc;
end
catch ME
    disp(ME)
end
%}    
    imagesc(xxx)
    
    for kk=1:max(ccc)-1
        xline(sum(ccc<kk+1)+0.5,'w-');
        % yline(szc(kk)+0.5,'w-');
    end
    set(gca,'YTick',1:size(xx,1));
    set(gca,'YTickLabel',markerlist);
    title(strrep(cLk,'_','\_'));
end

%}
