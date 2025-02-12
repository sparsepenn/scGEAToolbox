function [A0]=i_td1(XM0,methodid)
% TD - tensor decomposition for denoising
%
% input:  XM0 - k multi-layer network array (n x n x k)
% output: A0 - n x n adjacency matrix of denoised network

if nargin<2, methodid=1; end
    
    
switch methodid
    case 1
        Xhat0=ten.do_td_cp(XM0);        
    case 2
        Xhat0=ten.do_td_tucker(XM0);    
end
A0=mean(Xhat0,3);
end




