function trial_dat = eye_extract_trials(run_dat, p)

% Get number of timepoints
n_tp = size(run_dat,1)/p.n_trials;

trial_dat = [];
% For each run ...
for i_run = 1:size(run_dat, 3)
    % For each trial ...
    for i_trial = 1:p.n_trials

        % ... get the corresponding gaze data and append it to the
        % temporary data array
        s1 = n_tp*(i_trial-1)+1;
        s2 = n_tp*i_trial;
        trial_dat(:,:,i_trial,i_run) = run_dat(s1:s2,:,i_run);

    end
end

% Fill output array
trial_dat = permute(trial_dat, [3,2,4,1]);