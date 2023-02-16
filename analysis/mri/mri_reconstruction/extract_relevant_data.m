function extracted_data = extract_relevant_data(data, run_log, experiment, p)

% function extracted_data = extract_relevant_data(data, log, exp_struct, p)
% 
% Extract the relevant data for decoding.
%
% Input:
%   - data: [n_tr, n_voxel, n_run] array with data.
%   - run_log: Struct with one index per run. log.runNumber is adjusted so
%       that it counts from 1 to total_runs.
%   - experiment: Struct with all parameters of the experiment for the
%       current subejct.
%   - p: Structure with analysis parameters.
%
% Output:
%   - extracted_data: [n_trial, n_voxel, n_run, n_tr] array with extracted
%       data.
%
% Simon Weber, sweber@bccn-berlin.de, 2021

% Get relevant data dimension, i.e. number of runs
n_run = size(data,3);

% Get number of trials
n_trials = max(unique(run_log(1).log.trialNumber));

% Get (unsorted) labels
labels = extract_labels(run_log, experiment, p, 'unsorted');

% Initialize output variable
extracted_data = zeros(p.psvr.n_tr, size(data,2), n_trials, size(data,3));

% For each run...
for i_run = 1:n_run

    % Get current log
    curr_log = run_log(i_run).log;

    % Find relevant labels and stimulus onsets
    event = split(p.psvr.event, '_'); event = event{1};
    curr_onset = floor(curr_log.timing(strcmp(curr_log.event,event))./p.img.tr);
    curr_labels = labels(:,i_run);

    % Create array for each event TR (rows) and the following TRs (columns)
    tr_index = arrayfun(@(x) (x:x+p.psvr.n_tr -1), curr_onset, 'UniformOutput', false);
    tr_index = cell2mat(tr_index);
    
    % Sort trials in ascending order according to the labels to receive
    % indeces of relevant trials
    [curr_labels, sort_index] = sort(curr_labels);
    tr_index = tr_index(sort_index,:);
    
    % Extract the data of the relevant trials
    for i_trial = 1:size(tr_index,1)
        extracted_data(:,:,i_trial,i_run) = data(tr_index(i_trial,:),:,i_run);
    end
    
end

% Permute output dimensions for further processing
extracted_data = permute(extracted_data, [3,2,4,1]);
