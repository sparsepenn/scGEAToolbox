function [A0,A1]=i_td2(XM0,XM1,methodid)
% TD - tensor decomposition for denoising
%
% inputs:  XM0 - k multi-layer network array (n x n x k)
%          XM1 - k multi-layer network array (n x n x k)
% outputs: A0 - n x n adjacency matrix of denoised network
%          A1 - n x n adjacency matrix of denoised network

if nargin<3, methodid=1; end

if exist('@tensor/tensor.m','file')~=2
	error('Need Tensor Toolbox for MATLAB (https://www.tensortoolbox.org/)');
end

switch methodid
    case 1
        Xhat0=do_td_cp(XM0);
        Xhat1=do_td_cp(XM1);
    case 2
        Xhat0=do_td_tucker(XM0);
        Xhat1=do_td_tucker(XM1);
    case 3
        XM(:,:,:,1)=XM0;
        XM(:,:,:,2)=XM1;
        Xhat=do_td_cp(single(XM));
        Xhat0=Xhat(:,:,:,1);
        Xhat1=Xhat(:,:,:,2);
end
A0=mean(Xhat0,3);
A1=mean(Xhat1,3);
end
