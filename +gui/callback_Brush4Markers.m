function callback_Brush4Markers(src,~)
    FigureHandle=src.Parent.Parent;
    sce=guidata(FigureHandle);    
    assert(isequal(FigureHandle.Children, FigureHandle.findobj('type','Axes')))
    
    axesh=FigureHandle.Children(1);    
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
        methodtag=1;
    else
        answer = questdlg('Select brushed cell group?');
        if strcmp(answer,'Yes')
            if isscalar(unique(c(ptsSelected)))
                methodtag=2;
            else
                errordlg('More than one group of brushed cells');
                return;
            end
        elseif strcmp(answer,'No')
            methodtag=1;
        else
            return;
        end
    end
    fw=gui.gui_waitbar;
    
    switch methodtag
        case 1
            [markerlist]=sc_pickmarkers(sce.X,sce.g,1+ptsSelected,2);
        case 2
            [markerlist]=sc_pickmarkers(sce.X,sce.g,c,unique(c(ptsSelected)));
    end
    gui.gui_waitbar(fw);
    % assignin('base','A',A);
    [numfig]=gui.gui_inputdlg;
    fw=gui.gui_waitbar;
    htmlfilename=cL{unique(c(ptsSelected))};
    pkg.i_markergeneshtml(sce,markerlist,numfig,[ax bx],htmlfilename);
    gui.gui_waitbar(fw);
%     pause(2);
%     export2wsdlg({'Save marker list to variable named:'},...
%             {'g_markerlist'},{markerlist});
end
