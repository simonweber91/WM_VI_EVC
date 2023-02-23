function K = ME_GPR_kern(xi, xj, Kxx, L)
% _
% Kernels for Gaussian Process Regression
% 
% Author: Joram Soch, BCCN Berlin - joram.soch@bccn-berlin.de (JS)
% Other contributors: Felix Toepfer - felix.toepfer@bccn-berlin.de (FMT)

% First edit: 20/05/2019, 15:40 JS
% Last edit: 19/06/2019, 10:00 JS
% Added sinus Periodic Kernel: 08/01/2020, 14:53  FMT 


% Set defaults if necessary
%-------------------------------------------------------------------------%
if nargin < 3 || isempty(Kxx), Kxx = 'RBF'; end;
if nargin < 4 || isempty(L),   L   = [];    end;

% Create grid with all pairs
%-------------------------------------------------------------------------%
xi = repmat(xi', [size(xj,1) 1]);
xj = repmat(xj , [1 size(xi,2)]);

% Kernel: radial basis function
%-------------------------------------------------------------------------%
if strcmp(Kxx,'RBF')
    if isempty(L), sigma = 1/sqrt(2); else, sigma = L; end;
    K = exp(-((xi-xj).^2)./(2*sigma^2));
end;

% Kernel: circular radial basis function
%-------------------------------------------------------------------------%
if strcmp(Kxx,'cRBF')
    if isempty(L), sigma = pi/sqrt(2); else, sigma = L; end;
    dij = circ_dist(xi, xj);
    K   = exp(-(dij.^2)./(2*sigma^2));
end

% Kernel: von Mises distance
%-------------------------------------------------------------------------%
if strcmp(Kxx,'vMd')
    if isempty(L), kappa = 1/2; else, kappa = L; end;
    K = exp(kappa*(cos(xi-xj)-1));
end

% Kernel: periodic distance
%-------------------------------------------------------------------------%
if strcmp(Kxx,'per')
    if isempty(L), kappa = 1; else, kappa = L; end;
    K = 1*exp(-2*((sin(0.5*(xi-xj)))/kappa).^2);
end

end


% Function: circular distance
%-------------------------------------------------------------------------%
function d = circ_dist(x, y)
    d = x - y;
    i = abs(d)>pi;
    d(i) = -1*sign(d(i)) * 2*pi + d(i);
end