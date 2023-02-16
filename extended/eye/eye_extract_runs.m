function [run_dat, p] = eye_extract_runs(dat, event, p)

% Initialize output variables
run_dat = [];

% Define number of timepoints
n_tp = p.eye.seconds * p.eye.hz - 1;

% Identify run events
run_ind = [find(strcmp({event.type},'!MODE'))]';
run_events(:,1) = run_ind + 1;
run_events(:,2) = [run_ind(2:end); numel(event)];

% Check if skipping criteria are fulfilled
if numel(run_ind) ~= p.n_run, p.eye.skip = true; return; end

% Identify trial events
trial_ind = [find(strcmp({event.type},'trial'))];

% For each run...
for i_run = 1:numel(run_ind)
    
    % Get trials for current run
    trial_events = trial_ind(find(ismember(trial_ind,run_events(i_run,1):run_events(i_run,2))));
    
    % Check if skipping criteria are fulfilled
    if numel(trial_events) ~= p.n_trials, p.eye.skip = true; return; end

    % Get data for the trials
    trial_smp = [event(trial_events).sample];
    
    run_temp = [];
    % For each trial ...
    for i_trial = 1:numel(trial_smp)
        
        % ... get the corresponding gaze data and append it to the
        % temporary data array
        curr_smp = trial_smp(i_trial);
        curr_dat = [dat.gazex(curr_smp:curr_smp+n_tp)', dat.gazey(curr_smp:curr_smp+n_tp)'];
        run_temp = [run_temp; curr_dat];
    end
    
    % Fill output array
    run_dat(:,:,i_run) = run_temp;
    
end
    
    