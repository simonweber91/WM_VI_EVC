function tmass_stats = cluster_t_mass(perm_data, tail)

% function tmass_stats = cluster_t_mass(perm_data, tail)
% 
% Performs permutation-based cluster t-mass analysis.
% This approach determines clusters of subsequent time points with
% above-chance reconstruction accuracy based on t-tests. It then creates a
% null-distribution of cluster t-scores (the t-mass) from additional
% analyses that used permuted labels as input. The 'empirical' cluster
% t-scores can then be compared to the cluster t-mass to determine if these
% clusters could have arisen by chance or not.
%
% Input:
%   - perm_data: Array with analysis results. The 1st dimension contains
%       subjects, the 2dn dimension contains time points, the 3rd dimension
%       contains permutation. The empirical results have to be stored in
%       the first layer of the array, i.e. [:,:,1], with [:,:,2:end]
%       corresponding to the permutation-based results.
%   - tail: Specifies the direction of the performed t-test. Can be
%       'right','left' or 'both'.
%
% Output:
%   - tmass_stats: Structure containing all parameters and results about
%       the cluster t-mass analysis, including the empirical cluster,
%       significant time points and the entire t-mass.
%
% Simon Weber, sweber@bccn-berlin.de, 2022


% Get relevant data dimensions
n_tp = size(perm_data, 2);
n_perm = size(perm_data, 3) - 1;

% Check if 'tail' exists
if ~exist('tail','var') || isempty(tail) || ~any(strcmp(tail,{'right','left','both'}))
    error('Please specify type of test (one-tailed or two-tailed) as ''right'', ''left'' or ''both''.')
end

% Assign 'tail' to output variable
tmass_stats.tail = tail;


%%% Compute empirical statistics %%%

% Get empirical (non-permuted) data
empirical = perm_data(:,:,1);

% Compute empirical mean, confidence interval and standard deviation across
% subjects
emp_mean = mean(empirical);
emp_ci = get_ci95(empirical); emp_ci = emp_ci(2,:);
emp_std = std(empirical);

% Find clusters of subsequent time points with above-chance reconstruction
% accuracy
[emp_t, emp_cl] = find_significant_cluster(empirical, tail);

% Assign empirical stats to output variable
tmass_stats.empirical.data = empirical;
tmass_stats.empirical.mean = emp_mean;
tmass_stats.empirical.ci = emp_ci;
tmass_stats.empirical.std = emp_std;
tmass_stats.empirical.clusters = emp_cl;
tmass_stats.empirical.cluster_t = emp_t;

% If only empirical results exist, return
if n_perm == 0
    tmass_stats.empirical.cluster_p = NaN;
    tmass_stats.t_mass = NaN;
    tmass_stats.alpha = NaN;
    tmass_stats.cutoff_t = NaN;
    tmass_stats.sig_tp = nan(1,size(n_tp,2));
    return;
end


%%% Generate t-mass %%%

% Initialize t-mass
t_mass = zeros(1, n_perm);

% For each permutation instance...
for i_perm = 2:n_perm+1

    % Get data for current permutation
    curr_data = perm_data(:,:,i_perm);

    % Find significant clusters
    [cluster_t, clusters] = find_significant_cluster(curr_data, tail);

    % Assign highest cluster t-value to t-mass
    if ~isempty(cluster_t)
        t_mass(i_perm-1) = max(cluster_t);
    end

end


%%% Calculate stats %%%

% Sort t-mass
t_mass_sort = sort(abs(t_mass));

% Determine statistical threshold
if any(strcmp(tail,{'right', 'left'}))
    alpha = 0.05;
elseif strcmp(tail, 'both')
    alpha = 0.025;
end

% Find cutoff t-value in t-mass
cutoff = round(n_perm - n_perm * alpha); %one tailed
cutoff_t = t_mass_sort(cutoff); % 2 tailed iteration * 0.025

% Calculate p-values for empirical clusters
emp_p = zeros(1,numel(emp_t));
for i_p = 1:numel(emp_p)

    p_temp = abs(t_mass_sort - abs(emp_t(i_p)));
    p_temp = find(p_temp == min(p_temp));

    emp_p(i_p) = 1-(p_temp/n_perm);

end

% Find significant time points
sig_cl = abs(emp_t) > cutoff_t;

sig_ind = emp_cl(sig_cl,:);
sig_ind = sort(sig_ind(:));
sig_ind = sig_ind(sig_ind>0);

sig_tp = nan(1,n_tp);
sig_tp(sig_ind) = 1;


%%% Assign to output %%%

tmass_stats.empirical.cluster_p = emp_p;

tmass_stats.t_mass = t_mass;
tmass_stats.alpha = alpha;
tmass_stats.cutoff_t = cutoff_t;
tmass_stats.sig_tp = sig_tp;


