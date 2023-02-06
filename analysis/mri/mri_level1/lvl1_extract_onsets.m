function onsets = lvl1_extract_onsets(run_log, experiment, analysis)

% function onsets = lvl1_extract_onsets(run_log, experiment, analysis)
%
% Extract onset times of trial events for SPM first-level analysis.
%
% Input:
%   - run_log: Struct with one index per run. log.runNumber is adjusted so
%       that it counts from 1 to total_runs.
%   - experiment: Struct with all parameters of the experiment for the
%       current subejct.
%   - analysis: type of analysis to extract the correct onset times. All
%       requested analysis types have to have a corresponding case within
%       this function.
%
% Output:
%   - onsets: Structure with onset times for the required trial
%       event/experimental conditions. Each index of onset corresponds to
%       one experimental run.
%
% Simon Weber, sweber@bccn-berlin.de, 2020

% Initialize output variable
onsets = struct();

% Select the requested analysis type, then, for each experimental run,
% extract the onset times from the logfile
switch analysis
    
    case {'trial_events', 'delay_activation'}
        
        for i_run = 1:numel(run_log)
            
            log = run_log(i_run).log;
            
            onsets(i_run).target = log.timing(strcmp(log.event,'stimulus'));
            onsets(i_run).distractor = log.timing(strcmp(log.event,'distractor'));
            onsets(i_run).cue = log.timing(strcmp(log.event,'retrocue'));
            onsets(i_run).delay = log.timing(strcmp(log.event,'delay'));
            onsets(i_run).probe = log.timing(strcmp(log.event,'probe'));
            onsets(i_run).report = log.timing(strcmp(log.event,'response'));
            
        end
        
    case 'buttonpress'
        
        for i_run = 1:numel(run_log)
            
            log = run_log(i_run).log;
            
            onsets(i_run).right = log.timing(strcmp(log.event,'probe'));
            onsets(i_run).left = log.timing(strcmp(log.event,'response'));
            
        end
        
    case 'stimulus'
        
        for i_run = 1:numel(run_log)
            log = run_log(i_run).log;
            stim_log = log(strcmp(log.event,'stimulus'),:);
            
            samples = stim_log.value;
            [samples, si] = sort(samples);
            
            for i_sample = 1:numel(samples)
                onsets(i_run).(sprintf('sample%i',i_sample)) = round(stim_log.timing(si(i_sample)),1);      % round to first decimal
            end
        end
        
    case 'stimulus_pos2'
        
        for i_run = 1:numel(run_log)
            
            log = run_log(i_run).log;
            stim_log = log(strcmp(log.event,'stimulus'),:);
            
            position_index = experiment.Design.Run(i_run).trialInfo.stimPos;
            
            stim_log = stim_log(position_index==2,:);
            
            samples = stim_log.value;
            [samples, si] = sort(samples);
            
            for i_sample = 1:numel(samples)
                onsets(i_run).(sprintf('sample%i',i_sample)) = round(stim_log.timing(si(i_sample)),1);      % round to first decimal
            end
        end
        
    case 'stimulus_unsorted'

        for i_run = 1:numel(run_log)
            
            log = run_log(i_run).log;
            stim_log = log(strcmp(log.event,'stimulus'),:);
            
            samples = stim_log.value;
            
            for i_sample = 1:numel(samples)
                onsets(i_run).(sprintf('sample%i',i_sample)) = round(stim_log.timing(i_sample),1);      % round to first decimal
            end      
        end
end