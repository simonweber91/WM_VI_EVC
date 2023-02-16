function model = lvl1_specify(sub_id, p)

% function model = lvl1_specify(sub_id, p)
%
% Creates a design matrix for a SPM first-level analysis.
%
% Input:
%   - sub_id: ID of the current subject.
%   - p: Structure with analysis parameters.
%
% Output:
%   - model: Structure with all SPM settings used for this analysis
%       step (would be 'matlabbatch' in SPM).
%
% Simon Weber, sweber@bccn-berlin.de, 2020

% Exptract relevant variables from p
base_dir                = p.base_dir;
n_ses                   = p.n_session;
n_run                   = p.n_run;
filter                  = p.img.filter;
n_slice                 = p.img.n_slice;
tr                      = p.img.tr;
title                   = p.lvl1.title;
conditions              = p.lvl1.conditions;

% Get subject ID as string
sub_str                 = num2str(sub_id,'%02i');

% Initialize output variable
model = {};

% Check if output directory exists, create if not
out_dir = fullfile(base_dir, 'Nifti', ['sub-' sub_str], 'lvl1', title);
if ~exist(out_dir,'dir'), mkdir(out_dir); end

%%%% CAUTION: OVERWRITES SPM FILE!!! %%%%
if exist(fullfile(out_dir,'SPM.mat'),'file') && p.OVERWRITE == 1
    warning('FILES WILL BE OVERWRITTEN!!! If this was a mistake, abort now!');
    pause(5);
    
    delete(fullfile(out_dir,'*'));
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% Model Specification %%%
if ~exist(fullfile(out_dir,'SPM.mat'),'file')

    model{1}.spm.stats.fmri_spec.dir = {out_dir};                        % directory to write analysis files in
    model{1}.spm.stats.fmri_spec.timing.units = 'secs';                  % units for model design
    model{1}.spm.stats.fmri_spec.timing.RT = tr;                         % TR
    model{1}.spm.stats.fmri_spec.timing.fmri_t = n_slice;                % microtime resolution (=N)
    model{1}.spm.stats.fmri_spec.timing.fmri_t0 = round(n_slice/2);      % microtime onset (=N/2)

    % Load logfile and extract onset times
    [run_log, ~, experiment] = load_log(sub_id, p);
    onsets = lvl1_extract_onsets(run_log, experiment, title);

    % Check if onset fieldnames match the conditions specified in
    % p.conditions
    if ~isequal(conditions, fieldnames(onsets(1)))
        error('Extracted onset times and specified conditions do not match, please check!')
    end
    
    % For all sessions and runs...
    ct = 1;
    for i_ses = 1:n_ses
        ses_str = num2str(i_ses,'%02i');
        for i_run = 1:n_run
            run_str = num2str(i_run,'%02i');

            % List input images
            % Use only realigned images
            list = spm_select('ExtFPList', fullfile(base_dir, 'Nifti', ['sub-' sub_str], ['ses-' ses_str], 'func'), ['^rsub.*' filter '.*run-' run_str]);
            if ~isempty(list)
                files = cellstr(list);
            end
            model{1}.spm.stats.fmri_spec.sess(ct).scans = files;

            % Specify experimental conditions and corresponding onset times
            for i_cond = 1:numel(conditions)
                % Condition name
                model{1}.spm.stats.fmri_spec.sess(ct).cond(i_cond).name = conditions{i_cond};
                % Condition onsets
                cond_onsets = onsets(ct).(conditions{i_cond});
                if strcmp(conditions{i_cond},'delay')
                    model{1}.spm.stats.fmri_spec.sess(ct).cond(i_cond).onset = cond_onsets+2; 
                    model{1}.spm.stats.fmri_spec.sess(ct).cond(i_cond).duration = 6.4;
                else
                    model{1}.spm.stats.fmri_spec.sess(ct).cond(i_cond).onset = cond_onsets; 
                    model{1}.spm.stats.fmri_spec.sess(ct).cond(i_cond).duration = 0; % duration (0 for events)
                end
                % Additional parameters
                model{1}.spm.stats.fmri_spec.sess(ct).cond(i_cond).tmod = 0;     % time modulation (0: no)
                model{1}.spm.stats.fmri_spec.sess(ct).cond(i_cond).pmod = struct('name', {}, 'param', {}, 'poly', {});     % parametric modulations
                model{1}.spm.stats.fmri_spec.sess(ct).cond(i_cond).orth = 1;     % orthogonalise regressors within trial types (1: yes)
            end

            model{1}.spm.stats.fmri_spec.sess(ct).multi = {''};
            model{1}.spm.stats.fmri_spec.sess(ct).regress = struct('name', {}, 'val', {});
            % Add realignment parameters as additional regressors
            rp_file = dir(fullfile(base_dir, 'Nifti', ['sub-' sub_str], ['ses-' ses_str], 'func', ['rp_sub*' filter '_run-' run_str '*']));
            rp_file = fullfile(rp_file.folder, rp_file.name);
            model{1}.spm.stats.fmri_spec.sess(ct).multi_reg = {rp_file};
            model{1}.spm.stats.fmri_spec.sess(ct).hpf = 128; 

            ct = ct+1;
        end
    end

    % Additional parameters
    model{1}.spm.stats.fmri_spec.bases.hrf.derivs = [0 0];               % HRF derivatives (time, dispersion)
    model{1}.spm.stats.fmri_spec.volt = 1;                               % model interactions (volterra, 1: disabled)
    model{1}.spm.stats.fmri_spec.global = 'None';                        % global normalisation
    model{1}.spm.stats.fmri_spec.mthresh = 0.8;                          % masking threshold
    model{1}.spm.stats.fmri_spec.mask = {''};                            % explicit mask
    model{1}.spm.stats.fmri_spec.cvi = 'AR(1)';                          % serial correlations
    
    fprintf('\nSubject %d - 1st level specification.', sub_id)
    
    %%% Run %%%
    spm('defaults', 'FMRI'); 
    spm_jobman('run', model);

else
    warning('Subject %d - SPM file already exists, skip 1st level specification.', sub_id)
end