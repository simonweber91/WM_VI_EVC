function yCI95 = get_ci95(y, dim)

% function yCI95 = get_ci95(y, dim)
%
% Compute 95% confidence interval of input data y.
%
% Input:
%   - y: 2-D data array
%   - dim: Dimension along which to calculate 95% CI (default 1).
%
% Output:
%   - yCI95: 95% CI of y.
%
% Simon Weber, sweber@bccn-berlin.de, 2022

% Check id 'dim' exists and set default
if ~exist('dim', 'var') || isempty(dim)
    dim = 1;
end

% Transpose data according to 'dim'
if dim == 1
    y = y;
elseif dim == 2
    y = y';
else
    error('Error using dim: use 1 or 2 or leave empty for default (1).')
end

% Get number of observations (excluding NaNs)
N = repmat(size(y,1),1,size(y,2));
N = N - sum(isnan(y));

% Compute ostandard error of the mean of all observations
ySEM = std(y,'omitnan')./sqrt(N);

% Calculate 95% probability intervals of t-distribution
yCI95 = zeros(2,size(y,2));
for i = 1:size(y,2)
    CI95 = tinv([0.025 0.975], N(i)-1);
    yCI95(:,i) = bsxfun(@times, ySEM(i), CI95(:)); 
end