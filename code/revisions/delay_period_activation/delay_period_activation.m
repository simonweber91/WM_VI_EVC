

% Analysis scripts
% addpath(genpath('/.../WM_VI_EVC/code/analysis/'));
% addpath(genpath('/.../WM_VI_EVC/code/revisions/'));

% Toolboxes
% 1. SPM12
% https://www.fil.ion.ucl.ac.uk/spm/software/download/
% addpath('/.../spm12/');

%% Set Parameters

clear variables

%%% Create structure with key analysis parameters %%%

% Basic paramters
p.OVERWRITE             = 0;                                                % Do you want to overwrite already existing result files? Really???
% p.dirs.base              = '.../WM_VI_EVC';                                         % Base directory of the project, where all the stuff is stored.
% p.dirs.data              = fullfile(p.dirs.base, 'data');
p.dirs.source            = '';

% Number of sessions/runs-per-session/trials-per-run of the experiment
p.n_session             = 2;                                                % Number of fMRI scanning sessions
p.n_run                 = 4;                                                % Number of runs in one session
p.n_trials              = 40;                                               % Number of trials in one run

% Subject IDs
p.subjects = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 14, 15, 16, 17, 18, ...
              19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 33, 34, ...
              35, 36, 37, 38, 39, 40, 41, 42];                              % Subject IDs (i.e. number for the subject-specific BIDS directory)

% fMRI image aquisition details
p.img.n_slice           = 72;                                               % Number of slices in one fMRI image
p.img.tr                = 0.8;                                              % Length of TR in seconds
p.img.dim               = [104 104 72];                                     % fMRI image dimensions
% String-sample that defines the relevant fMRI images
p.img.filter            = 'task-vwm';                                       % String of a defining peice of the fMRI image filenames, so that they can be identified by loading scripts etc.

% First-level analysis parameters
p.lvl1.pp_filter        = 'swar';
p.lvl1.title            = 'delay_activation';                                   % What the first-level analysis should be called
p.lvl1.conditions       = {'target'; 'distractor'; 'cue'; 'delay'; 'probe'; 'report'};  % Which events to model
p.lvl1.contrasts        = {'delay'};                                       % Which events to contrast
p.lvl1.constrast_weights = { [repmat([0 0 0 1 0 0 zeros(1,6)],1,p.n_session*p.n_run)] };    % Contrast weights (including 6 zeros for head motion parameters, if needed)

p.lvl2.contrasts        = {'strong-weak' , 'weak-strong'};                                       % Which events to contrast
p.lvl2.constrast_weights = { [1 -1], [-1 1] };

%% Preprocessing

for i_sub = 1:numel(p.subjects)

    % Get subject ID
    sub_id = p.subjects(i_sub);
    
    % Run preprocessing steps (realignment, coregistration and segmentation
    % should already be completed from the main analysis)
    model = {};
%     model{end+1} = pp_realign(sub_id, p);
%     model{end+1} = pp_coregister(sub_id, p);
%     model{end+1} = pp_segment(sub_id, p);
    model{end+1} = pp_slicetime(sub_id, p);
    model{end+1} = pp_normalize_anat(sub_id, p);
    model{end+1} = pp_normalize_func(sub_id, p);
    model{end+1} = pp_smooth(sub_id, p);

    pp_save(sub_id, p, model);

end

%% 1st-level modeling

for i_sub = 1:numel(p.subjects)

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

%% 2nd-level modeling

model = {};
model{end+1} = lvl2_2samplettest_specify(p);
model{end+1} = lvl2_estimate(p);
model{end+1} = lvl2_contrasts(p);
lvl2_save(p, model)

try
    for i = 1:numel(p.lvl2.contrasts)
        img = imread(fullfile(p.dirs.data, 'Nifti', 'all', 'lvl2', p.lvl1.title, [p.lvl2.contrasts{i} '.png']));
        figure; image(img)
    end
end