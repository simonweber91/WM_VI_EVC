function bhvr = bhvr_load(p)

% function bhvr = bhvr_load(p)
%
% Loads behavioral data from the MRI experiment for all subjects.
%
% Input:
%   - p: Structure with analysis parameters.
%
% Output:
%   - bhvr: Structure with all relevant behavioral variables. Fields
%       include:
%       resp_err: Matrix with response errors, i.e. difference between target
%           and response orientations. Rows are trials, columns are subjects.
%       resp: Matrix with response orientations. Rows are trials, columns
%           are subjects.
%       target: Matrix with target orientations. Rows are trials, columns
%           are subjects.
%       distr: Matrix with distractor orientations. Rows are trials, columns
%           are subjects.
%       high: Logical array. 1 if the subject with the corresponding ID
%           belongs to the high imagery group, 0 otherwise.
%       low: Logical array. 1 if the subject with the corresponding ID
%           belongs to the low imagery group, 0 otherwise.
%       miss: Matrix with missed responses/trials. Rows are trials, columns
%           are subjects.
%
% Simon Weber, sweber@bccn-berlin.de, 2021

bhvr = struct();

try
% Initialize output variables
resp_err = [];              % error
resp = [];                  % response
target = [];                % target orientation (stimulus)
distr = [];                 % non-target orientation (distractor)
miss = [];                  % missing trials

% Initialize temporary variables
h_ind = [];
l_ind = [];

% Loop over subjects
for i_sub = 1:numel(p.subjects)

    % Get subject ID
    sub_id = p.subjects(i_sub);
    
    % Load logfile of the current subjects
    [run_log, full_log, Experiment] = load_log(sub_id, p);
    
    % Extract relevant values
    miss(:,i_sub) = isnan(full_log.value(strcmp(full_log.event,'response')));
    resp_err(:,i_sub) = full_log.value(strcmp(full_log.event,'response'));
    resp(:,i_sub) = full_log.value(strcmp(full_log.event,'probe'));
    target(:,i_sub) = full_log.value(strcmp(full_log.event,'stimulus'));
    distr(:,i_sub) = full_log.value(strcmp(full_log.event,'distractor'));
    
    % Store subject indeces for high/low group assignment
    if any(strcmp(Experiment.Subject.group,{'high','h'}))
        h_ind = [h_ind, i_sub];
    elseif any(strcmp(Experiment.Subject.group,{'low','l'}))
        l_ind = [l_ind, i_sub];
    end

end

% Remove data for missing trials
miss = logical(miss);
resp_err(miss) = NaN;
resp(miss) = NaN;
target(miss) = NaN;
distr(miss) = NaN;

% Assing high/low imagery groups
high = zeros(1,size(resp,2)); high(h_ind) = 1; high = logical(high);
low = zeros(1,size(resp,2)); low(l_ind) = 1; low = logical(low);

% Assign to output structure
bhvr.resp_err = resp_err;
bhvr.resp = resp;
bhvr.target = target;
bhvr.distr = distr;
bhvr.high = high;
bhvr.low = low;
bhvr.miss = miss;

catch
    warning('Behavioral data could not be loaded, likely because of missing log files.')
end