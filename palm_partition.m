function [X,Z,eC] = palm_partition(M,C,meth,Y)
% Partition a design matrix into regressors of interest and
% nuisance according to a given contrast.
% 
% Usage
% [X,Z] = partition(M,C,meth,Y)
% 
% Inputs:
% M    : Design matrix, to be partitioned.
% C    : Contrast that will define the partitioning.
% meth : Method for the partitioning. It can be:
%        - 'Guttman'
%        - 'Beckmann'
%        - 'Winkler'
%        - 'Ridgway'
% Y    : (Optional) For the 'Winkler' method only.
% 
% Outputs:
% X    : Matrix with regressors of interest.
% Z    : Matrix with regressors of no interest.
% eC   : Effective contrast, equivalent to the original,
%        for the partitioned model [X Z].
%
% References:
% * Guttman I. Linear Models: An Introduction. Wiley,
%   New York, 1982
% * Smith SM, Jenkinson M, Beckmann C, Miller K,
%   Woolrich M. Meaningful design and contrast estimability
%   in FMRI. Neuroimage 2007;34(1):127-36.
% * Ridgway GR. Statistical analysis for longitudinal MR
%   imaging of dementia. PhD thesis. 2009.
% * Winkler AM, Ridgway GR, Webster MG, Smith SM,
%   Nichols TE. Permutation inference for the general
%   linear model (in press).
% _____________________________________
% A. Winkler, G. Ridgway & T. Nichols
% FMRIB / University of Oxford
% Mar/2012 (1st version)
% Aug/2013 (this version)
% http://brainder.org

switch lower(meth),
    case 'guttman'
        idx = any(C~=0,2);
        X   = M(:,idx);
        Z   = M(:,~idx);
        eC  = C;
        
    case 'beckmann'
        C2  = null(C');
        Q   = pinv(M'*M);
        F1  = pinv(C'*Q*C);
        Pc  = C*pinv(C'*Q*C)*C'*Q;
        C3  = C2 - Pc*C2;
        F3  = pinv(C3'*Q*C3);
        X   = M*Q*C*F1;
        Z   = M*Q*C3*F3;
        eC  = vertcat(eye(size(X,2)),...
            zeros(size(Z,2),size(X,2)));
        
    case 'winkler'
        Q   = pinv(M'*M);
        X   = M*Q*C*pinv(C'*Q*C);
        Z   = (M*Q*M'-X*pinv(X))*Y;
        eC  = vertcat(eye(size(X,2)),...
            zeros(size(Z,2),size(X,2)));
        
    case 'ridgway'
        X     = M*pinv(C');
        C0    = eye(size(M,2)) - C*pinv(C);
        [Z,~] = svd(M*C0);
        Z     = Z(:,1:rank(M)-rank(C));
        X     = X-Z*(pinv(Z)*X);
        eC    = vertcat(eye(size(X,2)),...
            zeros(size(Z,2),size(X,2)));
        
    otherwise
        error('''%s'' - Unknown partitioning scheme',meth);
end