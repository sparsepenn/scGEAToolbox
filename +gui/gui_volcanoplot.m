function gui_volcanoplot(T)
x=T.avg_logFC;
y=-log10(T.p_val_adj);
y(y>100)=100;
%isok=T.pct_1>0.01|T.pct_2>0.01;
isok=abs(T.pct_2-T.pct_1)>0.015;
genelist=T.gene;

% figure;
ix=isinf(x) | abs(x)>10;
capv=1.05*max(abs(x(~ix)));
isx=sign(x);
x(ix)=capv;
x=isx.*abs(x);


scatter(x(isok),y(isok))
hold on
scatter(x(~isok),y(~isok),'xk')

glist=genelist(isok);
glist=[glist;genelist(~isok)];
% scatter(x,y)
ylabel('-log10(adj p-value)')
xlabel('log2(FC)')
yline(-log10(0.01),'r')
xline(-1,'r')
xline(1,'r')

dt=datacursormode;
dt.UpdateFcn = {@i_myupdatefcn1,glist};

end
        
function txt = i_myupdatefcn1(~,event_obj,g)
    idx = event_obj.DataIndex;
    txt = {g(idx)};
end
