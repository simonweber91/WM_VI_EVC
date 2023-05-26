function export = export_data(p)

data = [];
names = {};

%%% Load reconstruction data %%%

% Get relevant variables from 'p'
delay = p.psvr.delay;

% For each label...
for l = 1:numel(p.psvr.all_labels)

    p.psvr.label = p.psvr.all_labels{l};

    % Load results
    stats_file = dir(fullfile(p.dirs.data, 'analysis', 'all', 'results', ['pSVR_' p.psvr.event '_' p.psvr.label '_' p.psvr.roi '_stats.mat']));
    load(fullfile(stats_file.folder, stats_file.name), 'tmass_stats')
    bfca = tmass_stats.empirical.data;
    bfca_delay = mean(bfca(:,delay),2);

    data = [data, bfca_delay]; names = [names, ['BFCA ' p.psvr.label]];
end

%%% Load behavior data %%%

load(fullfile(p.dirs.data, 'analysis', 'all', 'results', 'bhvr.mat'), 'bhvr');
behavior = bhvr.vMMM.k_est(:,1);
data = [data, behavior]; names = [names, 'Behavior'];

%%% Load VVIQ data %%%

% Load VVIQ scores
[vviq, high, low] = vviq_scores(p);
data = [data, vviq]; names = [names, 'VVIQ pre'];

% Load post-scan questionnaire data
post_scan_file = dir(fullfile(p.dirs.data, 'questionnaire', 'post_scan.mat'));
if isempty(post_scan_file)
    warning('vviq.mat not found.');
    return;
end
load(fullfile(post_scan_file.folder, post_scan_file.name), 'post_scan')
data = [data, post_scan{:,:}]; names = [names, post_scan.Properties.VariableNames];

data = [data, low]; names = [names, 'Weak'];
data = [data, high]; names = [names, 'Strong'];

export = array2table(data, 'VariableNames', names);

export_name = fullfile(p.dirs.data, 'analysis', 'all', 'results', 'data_export.csv');
writetable(export, export_name, 'Delimiter', ',');

%% Correlation table for all relevant variables (Supplemental Information)

corr_table = export;
corr_table = removevars(corr_table, {'BFCA report','BFCA distractor','BFCA probe','Weak','Strong'});

[rho, pval] = corrcoef(corr_table{:,:});
rho = round(rho,3);
pval = round(pval,3);

rho_export = array2table(rho,'VariableNames', corr_table.Properties.VariableNames, 'RowNames', corr_table.Properties.VariableNames);

rho_export_name = fullfile(p.dirs.data, 'analysis', 'all', 'results', 'correlation_table.csv');
writetable(rho_export, rho_export_name, 'Delimiter', ',');

%% Table of descriptive statistics (Supplemental Information)

descriptive = [mean(corr_table{:,:}); std(corr_table{:,:}); skewness(corr_table{:,:}); kurtosis(corr_table{:,:})-3];
descriptive = round(descriptive,3);
descriptive_export = array2table(descriptive, 'VariableNames', corr_table.Properties.VariableNames, 'RowNames', {'Mean', 'Standard deviation', 'Skewness', 'Kurtosis (excess)'});

descriptive_export_name = fullfile(p.dirs.data, 'analysis', 'all', 'results', 'descriptive_stats.csv');
writetable(descriptive_export, descriptive_export_name, 'Delimiter', ',');
