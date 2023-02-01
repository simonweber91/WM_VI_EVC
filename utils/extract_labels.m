function labels = extract_labels(run_log, experiment, p, sorting, includenans)

% labels = extract_labels(run_log, exp_struct, p, sorting, includenans)
%
% Extract labels for reconstruction from experimental logfiles.
%
% Input:
%   - run_log: Struct with one index per run. log.runNumber is adjusted so
%       that it counts from 1 to total_runs.
%   - experiment: Struct with all parameters of the experiment for the
%       current subejct.
%   - p: Structure with analysis parameters.
%   - sorting: Wheteher labels should be sorted. Set to 'sorted' if labels
%       should be sorted in ascending order (for each run individually). Set to
%       'unsorted' to return labels in the order in which they appeared during
%       the experiment.
%   - includenans: Set to 'includenans' to replace labels from trials with
%       missing responses with NaN
%
% Output:
%   - labels: Matrix with labels. Rows represent trials, columns represent
%   runs.
%
% Simon Weber, sweber@bccn-berlin.de, 2021

% Check if labels should be returned unsorted and throw warning if
% appropriate.
if ~exist('sorting','var') || isempty(sorting) || ~any(strcmp(sorting,{'unsorted','sorted'}))
    warning('Labels will be returned unsorted. Use ''sorted'' or ''unsorted'' to specify.');
end

% Extract labels for the trial event specified in p.pre.label
labels = [];
switch p.psvr.label
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

end

% Scale labels to the range 0-360 degrees
labels = labels.*2;

% Check if labels should include NaNs and throw warning if appropriate.
if ~exist('includenans','var') || ~strcmp(includenans,'includenans')
    warning('Labels will be returned without missing trials (NaNs).')
    includenans = [];
end

% Return labels unsorted and with NaNs
if strcmp(sorting, 'unsorted') && strcmp(includenans,'includenans')
    resp = [];
    for i_run = 1:size(labels,2)
        resp(:,i_run) = run_log(i_run).log.value(strcmp(run_log(i_run).log.event,'response'));
    end
    nan_ind = find(isnan(resp));
    labels(nan_ind) = NaN;
end

% Retrun labels sorted and with NaNs
if strcmp(sorting, 'sorted') && strcmp(includenans,'includenans')
    for i_run = 1:size(labels,2)
        [labels(:,i_run), si] = sort(labels(:,i_run));
        
        resp = run_log(i_run).log.value(strcmp(run_log(i_run).log.event,'response'));
        resp = resp(si);
        nan_ind = find(isnan(resp));
        labels(nan_ind,i_run) = NaN;

    end
end

% Return labels sorted without NaNs
if strcmp(sorting, 'sorted') && isempty(includenans)
    for i_run = 1:size(labels,2)
        [labels(:,i_run), si(:,i_run)] = sort(labels(:,i_run));
    end
end



        
