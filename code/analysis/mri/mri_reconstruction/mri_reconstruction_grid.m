function mri_reconstruction_grid(p)

% Run the pSVR analysis as for a selection of voxel-counts and
% feature-space smoothing FWHM values (-> parameter grid-search). As it is
% not inherently clear which number of voxels or amount of smoothing yields
% the best reconstruction results for a given subject, the optimal value
% for these parameters is determined for each subject individually using a
% nested cross-validation across subjects (see pSVR_nested_cv.m).
% Using the thus determined optimal parameters, the data is then subjected
% to a permutation analysis (see mri_reconstruction_permute.m), in which
% the entire analysis is repeated x times with permuted labels to then
% determine timepoints with significantly above chance reconstruction
% accuracy using a permutation-based cluster t-mass analysis. (see
% cluster_t_mass.m)


% Run analysis
for i_sub = 1:numel(p.subjects)
% parallel_pool(p.par.n_workers);

    % Get subject ID
    sub_id = p.subjects(i_sub);

    % Check existing files, load recent temporary result file if necessary
    [analysis_complete, predictions, results, first_voxel, first_fwhm] = pSVR_check_progress_grid(sub_id, p);
    if analysis_complete == 1
        warning('Result file for subject %d already exists, continue with next subject', sub_id);
        continue;
    end

    % Load data and labels
    [data, mask, labels] = mri_get_data(sub_id, p);
    if isempty(data)
        warning('Subject %d - pSVR analysis cannot be performed.', sub_id);
        continue;
    end

    % Prepare labels for pSVR analysis and reconstruction
    [labels_psvr, labels_rad, missing] = pSVR_prepare_labels(labels);

    %%% Run analysis
    % For each voxel count...
    for i_voxel = first_voxel:numel(p.psvr.voxel)
        voxel_count = p.psvr.voxel(i_voxel);
        % For each fwhm value...
        for i_fwhm = first_fwhm:numel(p.psvr.fwhm)
            fwhm = p.psvr.fwhm(i_fwhm);

            % Prepare data for pSVR analysis
            [data_psvr, mask_psvr] = pSVR_prepare_data(data, mask, voxel_count, fwhm, labels);

            sin_pred = cell(1, p.psvr.n_tr); cos_pred = cell(1, p.psvr.n_tr); ang_pred = cell(1, p.psvr.n_tr); bfca = zeros(1, p.psvr.n_tr);

            % For each TR...
            for i_tr = 1:p.psvr.n_tr
%             parfor i_tr = 1:p.psvr.n_tr

                fprintf('Analysing: subject %d/%d - voxel_count %d/%d - fwhm %d/%d - TR %d/%d ... \n', i_sub, numel(p.subjects), i_voxel, numel(p.psvr.voxel), i_fwhm, numel(p.psvr.fwhm), i_tr, p.psvr.n_tr)

                % Run pSVR
                [sin_pred{i_tr}, cos_pred{i_tr}, ang_pred{i_tr}] = pSVR_predict(data_psvr(:,:,i_tr), labels_psvr, mask_psvr, missing, p);

                % Calculate balanced feature-continuous accuracy
                bfca(i_tr) = bal_norm_circ_resp_dev(ang_pred{i_tr}, labels_rad, 'trapz') .* 100;

            end
            % Assign predictions
            predictions.sin_pred(i_voxel, :, i_fwhm) = sin_pred;
            predictions.cos_pred(i_voxel, :, i_fwhm) = cos_pred;
            predictions.ang_pred(i_voxel, :, i_fwhm) = ang_pred;
            results.bfca(i_voxel, :, i_fwhm) = bfca;
            % Save temporary file
            pSVR_save_temp(sub_id, p, predictions, results, 'grid');
        end
    end

    % Save results
    pSVR_save(sub_id, p, predictions, results, 'grid');

end
