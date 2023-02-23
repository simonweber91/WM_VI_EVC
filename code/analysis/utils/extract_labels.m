function labels = extract_labels(run_log, experiment, label)

% labels = extract_labels(run_log, exp_struct, label)
%
% Extract labels for reconstruction from experimental logfiles.
%
% Input:
%   - run_log: Struct with one index per run. log.runNumber is adjusted so
%       that it counts from 1 to total_runs.
%   - experiment: Struct with all parameters of the experiment for the
%       current subejct.
%   - label: which label should be extracted
%
% Output:
%   - labels: Matrix with labels. Rows represent trials, columns represent
%   runs.
%
% Simon Weber, sweber@bccn-berlin.de, 2021

if isempty(run_log)
    warning('Labels cannot be extracted.')
    return;
end

% Extract labels for the trial event specified in p.pre.label
labels = [];
switch label
    case {'target', 'stimulus'}
        
        for i_run = 1:numel(run_log)
            labels(:,i_run) = run_log(i_run).log.value(strcmp(run_log(i_run).log.event,'stimulus'));
        end
        
    case {'report', 'response'}
        
        for i_run = 1:numel(run_log)
            labels(:,i_run) = run_log(i_run).log.value(strcmp(run_log(i_run).log.event,'probe'));
        end

    case 'distractor'
        
        for i_run = 1:numel(run_log)
            labels(:,i_run) = run_log(i_run).log.value(strcmp(run_log(i_run).log.event,'distractor'));
        end
        
    case 'probe'
        
        for i_run = 1:numel(run_log)
            labels(:,i_run) = experiment.Design.Run(i_run).trialInfo.probe;
        end

    case 'misses'

        for i_run = 1:numel(run_log)
            labels(:,i_run) = run_log(i_run).log.value(strcmp(run_log(i_run).log.event,'response'));
        end
        labels = isnan(labels);  

end

        
