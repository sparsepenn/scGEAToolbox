function callback_Brush4MarkersLASSO(src,~)
    FigureHandle=src.Parent.Parent;
    sce=guidata(FigureHandle);
%     assert(isequal(FigureHandle.Children,...
%         FigureHandle.findobj('type','Axes')))
    
    % axesh=FigureHandle.Children(1)
    axesh=FigureHandle.findobj('type','Axes');
    [ax,bx]=view(axesh);    
    assert(isequal(axesh.findobj('type','Scatter'),...
        FigureHandle.findobj('type','Scatter')))    
    h=axesh.Children(1);
    ptsSelected = logical(h.BrushData.');    
    
    if ~any(ptsSelected)
        warndlg("No cells are selected.");
        return;
    end
    assignin('base','ptsSelected',ptsSelected);
        
    [c,cL]=grp2idx(sce.c);
    if isscalar(unique(c))
        % methodtag=1;
    else
        answer = questdlg(sprintf('Select brushed cells'' group?\nYES to select brushed cells'' group\nNO to select brushed cells only'));
        switch answer
            case 'Yes'
                uptsSelected=unique(c(ptsSelected));
                if isscalar(uptsSelected)
                    % methodtag=2;   % whole group
                    ptsSelected=c==uptsSelected;
                else
                    errordlg('More than one group of brushed cells');
                    return;
                end
            case 'No'
                % methodtag=1;       % only selected cells 
            otherwise
                return;
        end
    end    
    [numfig]=gui.i_inputnumg;
    fw=gui.gui_waitbar;
    y=double(ptsSelected);
    sce.c=1+ptsSelected;
    X=sce.X';
    try
        if issparse(X) 
            X=full(X); 
        end
        [B]=lasso(X,y,'DFmax',numfig*3,'MaxIter',1e3);
    catch ME
        gui.gui_waitbar(fw);
        errordlg(ME.message);
        rethrow(ME);
    end
    % assignin('base','A',A);
    [~,ix]=min(abs(sum(B>0)-numfig));
    b=B(:,ix);
    idx=b>0;
    gui.gui_waitbar(fw);
    
    if ~any(idx)
        errordlg('No marker gene found')
        return;
    else
%         fw=gui.gui_waitbar;
         markerlist=sce.g(idx);
         [~,jx]=sort(b(idx),'descend');
         markerlist=markerlist(jx);
%         htmlfilename=cL{unique(c(ptsSelected))};
%         pkg.i_markergeneshtml(sce,markerlist,numfig,...
%                    [ax bx],htmlfilename,ptsSelected);
%         gui.gui_waitbar(fw);
        
        for kk=1:length(markerlist)
            f=figure;
            [h1]=sc_scattermarker(sce.X,sce.g,sce.s,...
                 markerlist(end-(kk-1)),5);
            view(h1,ax,bx);
            P = get(f,'Position');
            set(f,'Position',[P(1)-20*kk P(2)-20*kk P(3) P(4)]);
        end

       
    end
        fprintf('%d marker genes: ',length(markerlist));
        fprintf('%s ',markerlist)
        fprintf('\n')
%     pause(2);
%     export2wsdlg({'Save marker list to variable named:'},...
%             {'g_markerlist'},{markerlist});
end
