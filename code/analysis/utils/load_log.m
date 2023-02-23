function [run_log, full_log, experiment] = load_log(sub_id, p)

% function [run_log, full_log, Experiment] = load_log(sub_id, p)
%
% Load experimental logfiles of all sessions for one subject. Includes
% exceptions for each subject according to their specific experiment.
%
% Input:
%   - i_sub: ID of the current subject.
%   - p: Structure with analysis parameters.
%
% Output:
%   - run_log: Struct with one index per run. log.runNumber is adjusted so
%       that it counts from 1 to total_runs.
%   - full_log: Concatenated table for all runs across sessions.
%   - experiment: Struct with all parameters of the experiment for the
%       current subejct.
%
% Simon Weber, sweber@bccn-berlin.de, 2021

%%% Load Logfile, including subject-specific exceptions %%%

run_log = [];
full_log = [];
experiment = [];

% Get subject ID as string
sub_str = num2str(sub_id,'%02i');

check_file = dir(fullfile(p.dirs.data, 'logs', ['sub-' sub_str], 'ses-01', ['*' p.img.filter '*.mat']));
if isempty(check_file)
    warning('Subject %d - no log file found.', sub_id);
    return;
end

% Initialize variables
group_check = [0 0];

% Load logfile for each experimental session
for i_ses = 1:p.n_session

    % Get session ID as string
    ses_str = num2str(i_ses,'%02i');
    % Get filename of current logfile
    logfile = dir(fullfile(p.dirs.data, 'logs', ['sub-' sub_str], ['ses-' ses_str], ['*' p.img.filter '*.mat']));

    ses_log = [];
    
    %%% Load files %%%
    % Exceptions
    if sub_id == 2 && i_ses == 1

        load(fullfile(logfile(2).folder, logfile(2).name));
        ses_log = [Experiment.Log.Run(1).table; Experiment.Log.Run(2).table; Experiment.Log.Run(3).table];
        ex = Experiment;

        load(fullfile(logfile(3).folder, logfile(3).name));
        temp = Experiment.Log.Run(1).table;
        temp.runNumber(:) = 4;
        ses_log = [ses_log; temp];
        
        ex.Design.Run(4) = Experiment.Design.Run(1);
        ex.Log.Run(4) = Experiment.Log.Run(1);
        Experiment = ex;

    elseif sub_id == 5 && i_ses == 1

        load(fullfile(logfile(3).folder, logfile(3).name));
        ses_log = Log;

    elseif sub_id == 16 && i_ses == 1

        load(fullfile(logfile(2).folder, logfile(2).name));
        ses_log = Log;

    elseif sub_id == 26 && i_ses == 1

        load(fullfile(logfile(3).folder, logfile(3).name));
        ses_log = Log;    

    elseif sub_id == 27 && i_ses == 2

        load(fullfile(logfile(2).folder, logfile(2).name));
        ses_log = Log;

    elseif sub_id == 28 && i_ses == 1

        load(fullfile(logfile(2).folder, logfile(2).name));
        ses_log = [Experiment.Log.Run(1).table; Experiment.Log.Run(2).table; Experiment.Log.Run(3).table];
        ex = Experiment;

        load(fullfile(logfile(4).folder, logfile(4).name));
        temp = Experiment.Log.Run(1).table;
        temp.runNumber(:) = 4;
        ses_log = [ses_log; temp];
        
        ex.Design.Run(4) = Experiment.Design.Run(1);
        ex.Log.Run(4) = Experiment.Log.Run(1);
        Experiment = ex;

    elseif sub_id == 30 && i_ses == 2

        load(fullfile(logfile(3).folder, logfile(3).name));
        ses_log = Log;
    
    % Normal cases
    else   
        load(fullfile(logfile(1).folder, logfile(1).name));
        ses_log = Log;  
        
    end
    
    % Sanity check to see if experimental group is consistent in both
    % logfiles
    if ismember(Experiment.Subject.group,{'low','l'})
        group_check(i_ses) = -1;
    elseif ismember(Experiment.Subject.group,{'high','h'})
        group_check(i_ses) = 1;
    end
    
    % Combine Experiment structs across sessions
    if i_ses == 1
        ex = Experiment;
    else
        ex.Design.Run = [ex.Design.Run, Experiment.Design.Run];
        ex.Log.Run = [ex.Log.Run, Experiment.Log.Run];
    end
    
    % Adjust log.runNumber for higher sessions to count 1:total_runs
    if i_ses > 1
        for i_run = 1:p.n_run
            ses_log.runNumber(ses_log.runNumber==i_run) = (p.n_session-1)*p.n_run+i_run;
        end
    end
    
    % Append current log to full log
    full_log = [full_log; ses_log];

end

% Evaluate experimental group sanity check
if sum(group_check) ~= 2 && sum(group_check) ~= -2
    error(sprintf('groups don''t match in subject %s', num2str(sub_id)))
end

% Assign outoput variable
experiment = ex;

%%% Prepare Logfile for Pipeline %%%

% Prepare run_log struct with one index per run
total_runs = numel(unique(full_log.runNumber));
for i_run = 1:total_runs
    run_log(i_run).log = full_log(full_log.runNumber == i_run,:);
end



