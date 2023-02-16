function stats = tmass_permutation(all_results, all_predictions, p)

%% Parameters

n_sim = 1000;

win_size = 1; % 1 equals no smoothing % 50 for EEG

n_sub = numel(all_predictions);
n_run = size(all_predictions(1).ang_pred,2);
n_tr = size(all_predictions(1).ang_pred,3);

parallel_pool(22)

%% Find significant clusters in data

if size(all_results(1).bal_acc,1) == 1 && size(all_results(1).bal_acc,3) == 1
    BPrec = reshape([all_results.bal_acc],[],n_sub)';
    voxel_cv = ones(1,n_sub); fwhm_cv = ones(1,n_sub); 
else
    [BPrec, voxel_cv, fwhm_cv] = mtSVR_nested_cv(all_results, p);
    voxel_cv = voxel_cv(1,:); fwhm_cv = fwhm_cv(1,:); 
end

BPrec = BPrec - 50;

BPrec = moving_average(BPrec',win_size,1)';

BPrec_av = mean(BPrec);

BPrec_ci = get_ci95(BPrec);
BPrec_ci = BPrec_ci(2,:);

[t_cluster, clusters] = find_significant_cluster(BPrec);

stats.BPrec_av = BPrec_av;
stats.BPrec_ci = BPrec_ci;
stats.t_cluster = t_cluster;
stats.clusters = clusters;

%% Permutation simulation to generate t-mass

t_mass = zeros(1, n_sim);
for i_sim = 1:n_sim
        
    fprintf('simulation %d of %d\n', i_sim, n_sim)

    permuted_accuracy = zeros(n_sub,n_tr);
    for i_sub = 1:n_sub

        % get subject data
        ang_pred = all_predictions(i_sub).ang_pred(voxel_cv(i_sub),:,:,fwhm_cv(i_sub));
        true_labels = [all_predictions(i_sub).true_labels{1,:}]';
        
        % permute labels for each run
        rand_labels = zeros(size(true_labels));
        for i_run = 1:n_run
            rand_labels(i_run,:) = shuffle(true_labels(i_run,:));
        end
        rand_labels = rand_labels(:);
        rand_labels(isnan(rand_labels)) = [];

        % generate predictions from permuted labels
        perm_acc = zeros(n_tr,1);
        parfor i_tr = 1:n_tr

            curr_pred = [ang_pred{1,:,i_tr}];
            curr_pred = curr_pred';
            curr_pred = curr_pred(:);
            curr_pred(isnan(curr_pred)) = [];

            perm_acc(i_tr) = bal_norm_circ_resp_dev(curr_pred,rand_labels,'trapz').*100;

        end

        perm_acc = moving_average(perm_acc, 5, 1);
        permuted_accuracy(i_sub,:) = perm_acc';

    end

    permuted_accuracy = permuted_accuracy - 50;

    % find significant cluster for current simulation
    [t_cluster_sim, clusters_sim] = find_significant_cluster(permuted_accuracy);

    % find largest cluster and assign to t-mass
    if ~isempty(t_cluster_sim)
        t_mass(i_sim) = max(t_cluster_sim);
    else
        t_mass(i_sim) = 0;
    end

end

t_mass = sort(t_mass);

% assign p-values
pval = [];
for ic = 1:numel(t_cluster)

    t_ind = abs(t_mass-t_cluster(ic));
    t_ind = find(t_ind == min(t_ind));

    pval(ic) = 1-(t_ind/1000);

end

stats.p_cluster = pval;

stats.t_mass = t_mass;

%% Determine above threshold clusters in empirical data

% find significant clusters
cutoff = n_sim - n_sim * 0.05; %one tailed
cutoff = floor(cutoff);
critical_t = t_mass(cutoff); % 2 tailed iteration * 0.025
sig_cluster = t_cluster > critical_t;

% find significant timepoints
sig_tp = clusters(sig_cluster,:);
sig_tp = sort(sig_tp(:));
sig_tp = sig_tp(sig_tp>0);

% prepare vector for plotting
sig = nan(1,size(permuted_accuracy,2));
sig(sig_tp) = 1;

stats.significant = sig;


