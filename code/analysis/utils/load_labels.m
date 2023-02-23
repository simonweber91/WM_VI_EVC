function labels = load_labels(sub_id, p, sorting, includenans)

% labels = load_labels(sub_id, p, sorting, includenans)
%
% Load labels for reconstruction.
%
% Input:
%   - i_sub: ID of the current subject.
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

labels = [];

% Get subject ID as string
sub_str = num2str(sub_id,'%02i');

% Load all labels
logfile = dir(fullfile(p.dirs.data, 'analysis', ['sub-' sub_str], 'labels', ['task_labels.mat']));
if isempty(logfile)
    warning('Subject %d - no labels available.', sub_id);
    return;
end

load(fullfile(logfile.folder, logfile.name))

% Check if labels should be returned unsorted and throw warning if
% appropriate.
if ~exist('sorting','var') || isempty(sorting) || ~any(strcmp(sorting,{'unsorted','sorted'}))
    warning('Labels will be returned unsorted. Use ''sorted'' or ''unsorted'' to specify.');
end

% Get required labels
labels = task_labels.(p.psvr.label);

% Scale labels to the range 0-360 degrees
labels = labels.*2;


% Check if labels should include NaNs and throw warning if appropriate.
if ~exist('includenans','var') || ~strcmp(includenans,'includenans')
    warning('Labels will be returned without missing trials (NaNs).')
    includenans = [];
end

% Return labels unsorted and with NaNs
if strcmp(sorting, 'unsorted') && strcmp(includenans,'includenans')
    labels(task_labels.misses) = NaN;
end

% Retrun labels sorted and with NaNs
if strcmp(sorting, 'sorted') && strcmp(includenans,'includenans')
    for i_run = 1:size(labels,2)
        [labels(:,i_run), si] = sort(labels(:,i_run));
        
        miss = task_labels.misses(:,i_run);
        miss = miss(si);
        labels(miss,i_run) = NaN;

    end
end

% Return labels sorted without NaNs
if strcmp(sorting, 'sorted') && isempty(includenans)
    for i_run = 1:size(labels,2)
        [labels(:,i_run), si(:,i_run)] = sort(labels(:,i_run));
    end
end




