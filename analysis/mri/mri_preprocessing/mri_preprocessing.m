function mri_preprocessing(p)

% Run a number of preprocessing steps on the fMRI data. The analysis is
% based on realigned (but otherwise raw) data, so this is the only
% essential preprocessing step for the analysis. We also run coregistration
% and segmentation to estimate transformation-fields from MNI to subject
% space, in order to warp ROIs for each subject.

for i_sub = 1:numel(p.subjects)
% parallel_pool(p.par.n_workers);
% parfor i_sub = p.subjects

    % Get subject ID
    sub_id = p.subjects(i_sub);
    
    % Run preprocessing steps
    model = {};
    model{end+1} = pp_realign(sub_id, p);
    model{end+1} = pp_coregister(sub_id, p);
    model{end+1} = pp_segment(sub_id, p);

    pp_save(sub_id, p, model);

end
