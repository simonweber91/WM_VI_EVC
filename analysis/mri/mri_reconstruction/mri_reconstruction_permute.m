function mri_reconstruction_permute(p)

% Run the pSVR analysis as for the optimal values for voxel-counts and
% feature-space smoothing FWHM values. First, the results from the
% parameter grid-search analysis (see mri_reconstruction_grid.m) are loaded
% and submitted to a nested cross-validation across subject, in which the
% optimal parameters for each subject are determined on the basis of all
% other subjects (see pSVR_nested_cv.m). Next, these parameters are used in
% a permutation analysis, where the entire analysis is repeated x times
% (usually: x = 1000) wiht permuted labels. These permutation results are
% then used to determine timepoints with significantly above chance
% reconstruction accuracy using a permutation-based cluster t-mass
% analysis. (see cluster_t_mass.m)


% Load results of grid-search pSVR analysis
all_results = pSVR_load_results(p, 'grid');
% Run nested cross-validation across subjects to determine optimal values
% for voxel-count and feature-space smoothing fwhm
[bfca_cv, voxel_cv, fwhm_cv] = pSVR_nested_cv(all_results, p);

% Run analysis
for i_sub = 1:numel(p.subjects)
% parallel_pool(p.par.n_workers);

    % Get subject ID
    sub_id = p.subjects(i_sub);

    % Update a subject-specific p-Strcuture with the appropriate
    % voxel-count and fwhm values
    sub_p = p;
    sub_p.psvr.voxel = voxel_cv(2,i_sub);
    sub_p.psvr.fwhm = fwhm_cv(2,i_sub);
    
    % Check existing files, load recent temporary result file if necessary
    [analysis_complete, predictions, results, first_perm] = pSVR_check_progress_permute(sub_id, sub_p);
    if analysis_complete == 1
        warning('Result file for subject %d already exists, continue with next subject', sub_id);
        continue;
    end

    % Load data and labels
    [data, mask, labels] = mri_get_data(sub_id, sub_p);

    % Prepare labels for pSVR analysis and reconstruction
    [labels_psvr, labels_rad, missing] = pSVR_prepare_labels(labels);

    % Prepare data for pSVR analysis
    [data_psvr, mask_psvr] = pSVR_prepare_data(data, mask, sub_p.psvr.voxel, sub_p.psvr.fwhm, labels);

    for i_perm = first_perm:p.psvr.n_perm

        % Permute labels
        perm_ind = randperm(numel(labels_psvr));
        labels_psvr_perm = labels_psvr(perm_ind);
        labels_rad_perm = labels_rad(perm_ind);

        for i_tr = 1:sub_p.psvr.n_tr
        % parfor i_tr = first_tr:p.psvr.n_tr

            fprintf('Analysing: subject %d/%d - permutation %d/%d - TR %d/%d ... \n', i_sub, numel(p.subjects), i_perm, p.psvr.n_perm, i_tr, p.psvr.n_tr)
            
            % Run pSVR
            [sin_pred, cos_pred, ang_pred] = pSVR_predict(data_psvr(:,:,i_tr), labels_psvr_perm, mask_psvr, missing, sub_p);

            % Assign predictions
            predictions.sin_pred{i_perm, i_tr} = sin_pred;
            predictions.cos_pred{i_perm, i_tr} = cos_pred;
            predictions.ang_pred{i_perm, i_tr} = ang_pred;
            % Calculate balanced feature-continuous accuracy
            results.bfca(i_perm, i_tr) = bal_norm_circ_resp_dev(ang_pred, labels_rad_perm, 'trapz') .* 100;

        end
        % Save temporary file
        pSVR_save_temp(sub_id, sub_p, predictions, results, 'permute');
    end

    % Save file
    pSVR_save(sub_id, sub_p, predictions, results, 'permute')

end

