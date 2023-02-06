function [t_cluster, clusters] = find_significant_cluster(data, tail)

% function [t_cluster, clusters] = find_significant_cluster(data, tail)
%
% Find clusters of subsequent time points with above-chance reconstruction
% accuracy based on t-tests.
% 
% Input:
%   - data: 2-D data array, 1st dimension are subjects and 2nd dimension
%       are time points.
%   - tail: Specifies the direction of the performed t-test. Can be
%       'right','left' or 'both'.
%
% Output:
%   - t-cluster: vector of summed t-scores for each cluster of time-points.
%   - clusters: array of significant clusters. Rows are clusters, columns
%       hold the indeces of the time points that belong to that cluster.
%
% Simon Weber, sweber@bccn-berlin.de, 2022

% Check if 'tail' exists
if ~exist('tail','var') || isempty(tail) || ~any(strcmp(tail,{'right','left','both'}))
    error('Please specify type of test (one-tailed or two-tailed) as ''right'', ''left'' or ''both''.')
end

% Compute t-test of the data
[h, p_val, ci, stats] =  ttest(data, 0, 'Tail', tail);

% Extract t-score
tstat = stats.tstat;

%%% Remove single significant timepoints %%%

h_adj = zeros(size(h));
% Remove single significant timepoints
for i_h = 1:numel(h)
    if i_h == 1
        % If there is a single significant timepint in position 1 ignore
        % it, else keep it
        if h(i_h) == 1 && h(i_h+1) == 0
            h_adj(i_h) = 0;
        else
            h_adj(i_h) = h(i_h);
        end
    elseif i_h == numel(h)
        % If there is a single significant timepint in last position ignore
        % it, else keep it
        if h(i_h-1) == 0 && h(i_h) == 1
            h_adj(i_h) = 0;
        else
            h_adj(i_h) = h(i_h);
        end
    else
        % If there is a single significant timepint anywhere else ignore
        % it, else keep it
        if h(i_h-1) == 0 && h(i_h) == 1 && h(i_h+1) == 0
            h_adj(i_h) = 0;
        else
            h_adj(i_h) = h(i_h);
        end
    end
end

%%% Find clusters of timepoints %%%

% Find how many clusters there are and compute summed T-score of each
% cluster. Creates a matrix with number of clusters as rows and indices of
% cluster members as columns.

clusters = [];
cl = 0;         % cluster counter
member = 0;     % indeces of time points in a cluster

% Check if time point 1 is part of a cluster
if h_adj(1) == 1 && h_adj(2) == 1
    cl = cl+1;
    member = member +1;
    clusters(cl,member) = 1;
end
% Check if the following time points are part of a cluster
for i = 2:length(h_adj)-1
    % If it's the first of a cluster, create new cluster
    if h_adj(i-1) == 0 && h_adj(i) == 1 && h_adj(i+1) == 1
        cl = cl+1;
        member = member +1;
        clusters(cl, member) = i;
    % If it's the last of a cluster, finish cluster
    elseif h_adj(i-1) ==1 && h_adj(i) == 1 && h_adj(i+1) == 0
        member = member +1;
        if cl == 0
            cl = cl+1; % in case first index in clusters equals 1
        end
        clusters(cl, member) = i;
        member = 0;
    % If it's in the middle of a cluster, add to cluster
    elseif h_adj(i-1) ==1 && h_adj(i) == 1 && h_adj(i+1) == 1
        member = member +1;
        if cl == 0
            cl = cl+1; % in case first index in clusters equals 1
        end
        clusters(cl,member) = i;
    end
end
% Check if the last time point is part of a cluster
if h_adj(end-1) == 1 && h_adj(end) == 1
    member = member +1;
    clusters(cl,member) = length(h_adj);
end

%%% Compute summed T of each cluster %%%

n_cluster = cl;
t_cluster = zeros(1,n_cluster);
for i_cl = 1:n_cluster
    t_cluster(i_cl) = sum(tstat(clusters(i_cl, clusters(i_cl,:) ~=0)));
end
