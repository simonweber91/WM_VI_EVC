function post_scan = post_scan_load(p)

% function post_scan = post_scan_load(p)
%
% Load data of the post scan questionnaires, including the VVIQ, the OSIQ
% and a strategy questionnaire.
%
% Output:
%   - post_scan: Table of questionnaire data.
%
% Simon Weber, sweber@bccn-berlin.de, 2021

post_scan = [];

post_scan_out = dir(fullfile(p.dirs.data, 'questionnaire', 'post_scan.mat'));
if ~isempty(post_scan_out) && ~p.OVERWRITE
    warning('post_scan.mat already exists.');
    return;
end

% Load questionnaire data
post_scan_file = fullfile(p.dirs.data, 'questionnaire', 'post_scan_public.mat');
if ~exist(post_scan_file, 'file')
    warning('post_scan_public.mat not found. Please make sure that VVIQ.mat is stored in %s.', fullfile(p.dirs.data, 'questionnaire'))
    return;
end

load(post_scan_file);

post_scan = post_scan(:,[3,4,5,52:58]);
post_scan.Properties.VariableNames = {'VVIQ post', 'OSIQ visual', 'OSIQ spatial', 'Strategy visual', 'Strategy verbal', 'Strategy spatial', 'Strategy cardinal', 'Strategy time', 'Strategy code', 'Strategy other'};

% Compute strategy ratios
strat = post_scan{:,4:10}-1;
strat = strat./sum(strat,2);
post_scan{:,4:10} = strat;

save(fullfile(p.dirs.data, 'questionnaire', 'post_scan.mat'), 'post_scan')
