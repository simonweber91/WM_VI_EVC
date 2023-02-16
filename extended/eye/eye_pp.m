function [eye, p] = eye_pp(i_sub, p)

% Get subject ID as string
sub_str = num2str(i_sub,'%02i');

% Initialize output variables
eye = [];

% Check if subject has the right number of .asc files (each only has one
% per session)
f1 = dir(fullfile(p.base_dir, 'Nifti', ['sub-' sub_str], 'ses-01', 'eye', '*.asc'));
f2 = dir(fullfile(p.base_dir, 'Nifti', ['sub-' sub_str], 'ses-02', 'eye', '*.asc'));
% Check if skipping criteria are fulfilled
if numel(f1) + numel(f2) ~= 2, p.eye.skip = true; warning('Skipping subject %s due to missing data.', sub_str); return; end

% For each session...
for i_ses = 1:p.n_session

    % Initialize variables
    run_events = []; eye_temp = [];

    % Get session ID as string
    ses_str = num2str(i_ses,'%02i');

    % Read ASC file
    asc_file = dir(fullfile(p.base_dir, 'Nifti', ['sub-' sub_str], ['ses-' ses_str], 'eye', '*.asc'));
    asc_file = fullfile(asc_file.folder, asc_file.name);
    asc = read_eyelink_ascNK_AU(asc_file);

    % Convert ASC to DAT (fieldtrip) format
    [data, event, blinksmp, saccsmp] = asc2dat(asc);

    % Interpolate blinks
    plot_me = false;
    [newpupil, newblinksmp, nanIdx, dat] = blink_interpolate(data, blinksmp, plot_me);
    dat.saccsmp = saccsmp;

    % Bandpass filter
    dat = filter_eye(dat, p);

    % Extract run data
    [run_dat, p] = eye_extract_runs(dat, event, p);
    % Check if skipping criteria are fulfilled
    if p.eye.skip, break; end

    % Fill output array
    eye = cat(3, eye, run_dat);

end

% Check if skipping criteria are fulfilled
if p.eye.skip, warning('Skipping subject %s due to incomplete data.', sub_str); return; end

% Temporal detrending using cubic spline interpolation
eye = detrend_spline(eye, p.n_trials/2);

% Extract trial data
eye = eye_extract_trials(eye, p);

% Downsample data
eye = eye_downsample_data(eye, p);


