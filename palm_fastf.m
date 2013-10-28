function [G,df2] = palm_fastf(M,psi,res,plm,c)
% This function is a simplification of 'pivotal.m',
% without argument checking and that works only if:
% - rank(contrast) > 1
% - number of variance groups = 1
% 
% Inputs:
% M   : design matrix
% psi : regression coefficients
% res : residuals
% plm : a struct with many things as generated by
%       'palm.m' and 'takeargs.m'
% 
% Outputs:
% G   : In this particular case, G is the F-statistic.
% df2 : Degrees of freedom 2. df1 is simply rank(C) and
%       is not returned for speed and compatibility.
%
% For the full explanation, see the generic, but much
% slower 'pivotal.m'
%  
% _____________________________________
% Anderson Winkler and Tom Nichols
% FMRIB / University of Oxford
% Aug/2013
% http://brainder.org

df2 = plm.tmp.N-plm.tmp.rM;
cte = plm.tmp.eC*inv(plm.tmp.eC'*inv(M'*M)*plm.tmp.eC)*plm.tmp.eC'; %#ok inv here

tmp = zeros(size(psi));
for j = 1:size(cte,2),
    tmp(j,:) = sum(bsxfun(@times,psi,cte(:,j)))';
end
G = sum(tmp.*psi);
ete = sum(res.^2);
G = G./ete * (df2/plm.tmp.rC(c));