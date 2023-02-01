function mri_level1(p)

% Run a first-level GLM on the fMRI data, to model brain activation in
% response to the target and other trial events (distractor, cue, delay
% onset, probe onset, report). The aim is to calculate a
% target-vs.-baseline contrast, which is then used to select voxels for the
% reconstruction analysis based on the strength of their response to the
% target stimulus.

for i_sub = 1:numel(p.subjects)
% parallel_pool(p.par.n_workers);
% parfor i_sub = p.subjects

    % Get subject ID
    sub_id = p.subjects(i_sub);

    % Run fist-level model
    model = {};
    model{end+1}    = lvl1_specify(sub_id, p);
    model{end+1}    = lvl1_estimate(sub_id, p);
    model{end+1}    = lvl1_contrasts(sub_id, p);
    
    copy_brain_mask(sub_id, p);

    lvl1_save(sub_id, p, model);
        
end
