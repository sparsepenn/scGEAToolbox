function i_doublegraphs(G1,G2)
if nargin<2
    G1=WattsStrogatz(100,5,0.15);
    G2=WattsStrogatz(100,5,0.15);
    G1.Nodes.Name = string((1:100)');
    G2.Nodes.Name = string((1:100)');
    G1.Edges.Weight=rand(size(G1.Edges,1),1)*2;
    G2.Edges.Weight=rand(size(G2.Edges,1),1)*2;
end
assert(isequal(G1.Nodes.Name,G2.Nodes.Name));
import gui.*
%%

b=2;
hFig=figure;
h1=subplot(1,2,1);
% p1=plot(G1);
[p1]=drawnetwork(G1,h1);

h2=subplot(1,2,2);
% p2=plot(G2);
[p2]=drawnetwork(G2,h2);
p2.XData=p1.XData;
p2.YData=p1.YData;

tb = uitoolbar(hFig);
pt = uipushtool(tb,'Separator','off');
ptImage = rand(16,16,3);
pt.CData = ptImage;
pt.Tooltip = 'ChangeFontSize';
pt.ClickedCallback = @ChangeFontSize;

pt = uipushtool(tb,'Separator','off');
ptImage = rand(16,16,3);
pt.CData = ptImage;
pt.Tooltip = 'ChangeWeight';
pt.ClickedCallback = @ChangeWeight;

pt = uipushtool(tb,'Separator','off');
ptImage = rand(16,16,3);
pt.CData = ptImage;
pt.Tooltip = 'ChangeLayout';
pt.ClickedCallback = @ChangeLayout;

pt = uipushtool(tb,'Separator','off');
ptImage = rand(16,16,3);
pt.CData = ptImage;
pt.Tooltip = 'ChangeDirected';
pt.ClickedCallback = @ChangeDirected;

pt = uipushtool(tb,'Separator','off');
ptImage = rand(16,16,3);
pt.CData = ptImage;
pt.Tooltip = 'ChangeCutoff';
pt.ClickedCallback = @ChangeCutoff;

pt = uipushtool(tb,'Separator','off');
ptImage = rand(16,16,3);
pt.CData = ptImage;
pt.Tooltip = 'AnimateCutoff';
pt.ClickedCallback = @AnimateCutoff;

hFig.Position(3)=hFig.Position(3)*2.2;
                
   function ChangeFontSize(hObject,event)
       i_changefontsize(p1);
       i_changefontsize(p2);
       function i_changefontsize(p)
           if p.NodeFontSize>=20
               p.NodeFontSize=7;
           else
               p.NodeFontSize=p.NodeFontSize+1;
           end
       end
   end

   function ChangeWeight(hObject,event)
       a=3:10;
       b=a(randi(length(a),1));       
       i_changeweight(p1,G1,b);
       i_changeweight(p2,G2,b);
       function i_changeweight(p,G,b)
           if length(unique(p.LineWidth))>1
            p.LineWidth = p.LineWidth./p.LineWidth;
           else
            G.Edges.LWidths = abs(b*G.Edges.Weight/max(G.Edges.Weight));
            p.LineWidth = G.Edges.LWidths;
           end
       end
   end

   function ChangeLayout(hObject,event)
       a=["layered","subspace","force","circle"];       
       i=randi(length(a));
       p1.layout(a(i));
       p2.layout(a(i));
       p2.XData=p1.XData;
       p2.YData=p1.YData;
   end

   function ChangeDirected(hObject,event)
       [p1,G1]=i_changedirected(p1,G1,h1);
       [p2,G2]=i_changedirected(p2,G2,h2);
       function [p,G]=i_changedirected(p,G,h) 
        x=p.XData; y=p.YData;
        if isa(G,'digraph')
            A=adjacency(G,'weighted');
            G=graph(0.5*(A+A.'),G.Nodes.Name);
            % p=plot(h,G);
            [p]=drawnetwork(G,h);
        end
        p.XData=x; p.YData=y;
       end
   end

   function ChangeCutoff(hObject,event)
        list = {'0.00 (show all edges)',...
            '0.30','0.35','0.40','0.45',...
            '0.50','0.55','0.60',...
            '0.65','0.70','0.75','0.80','0.85',...
            '0.90','0.95 (show 5% of edges)'};
        [indx,tf] = listdlg('ListString',list,...
            'SelectionMode','single','ListSize',[160,230]);
        if tf
            if indx==1
                cutoff=0;
            elseif indx==length(list)
                cutoff=0.95;
            else
                cutoff=str2double(list(indx));
            end
            %A1=e_transf(adjacency(G1,'weighted'),cutoff);
            %A2=e_transf(adjacency(G2,'weighted'),cutoff);
            [p1]=i_replotg(p1,G1,h1,cutoff);
            [p2]=i_replotg(p2,G2,h2,cutoff);
        end
%        function [p,G]=i_replotg(p,G,h,cutoff) 
%         x=p.XData; y=p.YData;
%         A=adjacency(G,'weighted');
%         A=e_transf(A,cutoff);
%         if issymmetric(A)
%             G=graph(A,G.Nodes.Name);
%         else
%             G=digraph(A,G.Nodes.Name);
%         end
%         % p=plot(h,G);
%         [p]=drawnetwork(G,h);
%         p.XData=x; p.YData=y;
%        end
        
   end


    function [p]=drawnetwork(G,h)
        p=plot(h,G);
        layout(p,'force');
        if isa(G,'digraph')
            G.Nodes.NodeColors = outdegree(G)-indegree(G);
        else
            G.Nodes.NodeColors = degree(G);            
        end
        p.NodeCData = G.Nodes.NodeColors;
        n=size(G.Edges,1);
        cc=repmat([0 0.4470 0.7410],n,1);
        cc(G.Edges.Weight<0,:)=repmat([0.8500, 0.3250, 0.0980],...
               sum(G.Edges.Weight<0),1);
        p.EdgeColor=cc;
        p.NodeFontSize=2*p.NodeFontSize;
        title(h,'scGRN');
        
           if length(unique(p.LineWidth))>1
            p.LineWidth = p.LineWidth./p.LineWidth;
           else
            G.Edges.LWidths = abs(b*G.Edges.Weight/max(G.Edges.Weight));
            p.LineWidth = G.Edges.LWidths;
           end
        
    end

   function AnimateCutoff(hObject,event)
        listc = 0.05:0.05:0.95; 
        for k=1:length(listc)
            cutoff=listc(k);
            p1=i_replotg(p1,G1,h1,cutoff);
            p2=i_replotg(p2,G2,h2,cutoff);
            pause(3);
        end
   end

   function [p,G]=i_replotg(p,G,h,cutoff) 
    x=p.XData; y=p.YData;
    A=adjacency(G,'weighted');
    A=e_transf(A,cutoff);
    if issymmetric(A)
        G=graph(A,G.Nodes.Name);
    else
        G=digraph(A,G.Nodes.Name);
    end
    % p=plot(h,G);
    [p]=drawnetwork(G,h);
    p.XData=x; p.YData=y;
   end



end




function h = WattsStrogatz(N,K,beta)
% H = WattsStrogatz(N,K,beta) returns a Watts-Strogatz model graph with N
% nodes, N*K edges, mean node degree 2*K, and rewiring probability beta.
%
% beta = 0 is a ring lattice, and beta = 1 is a random graph.

% Connect each node to its K next and previous neighbors. This constructs
% indices for a ring lattice.
s = repelem((1:N)',1,K);
t = s + repmat(1:K,N,1);
t = mod(t-1,N)+1;

% Rewire the target node of each edge with probability beta
for source=1:N    
    switchEdge = rand(K, 1) < beta;
    
    newTargets = rand(N, 1);
    newTargets(source) = 0;
    newTargets(s(t==source)) = 0;
    newTargets(t(source, ~switchEdge)) = 0;
    
    [~, ind] = sort(newTargets, 'descend');
    t(source, switchEdge) = ind(1:nnz(switchEdge));
end

h = graph(s,t);
end
