function pSVR_plot_delay_accuracy(p)

% Get relevant variables from 'p'
delay = p.psvr.delay;
p.psvr.label = 'target';

%%% Prepare data %%%

% Load results
stats_file = dir(fullfile(p.dirs.data, 'analysis', 'all', 'results', ['pSVR_' p.psvr.event '_' p.psvr.label '_' p.psvr.roi '_stats.mat']));
if isempty(stats_file)
    warning('No stats file, cannot plot.');
    return;
end
load(fullfile(stats_file.folder, stats_file.name), 'tmass_stats')
bfca_cv = tmass_stats.empirical.data;

% Load VVIQ scores
[vviq_score, high, low] = vviq_scores(p);
if isempty(high) || isempty(low)
    warning('No vviq data, cannot plot.');
    return;
end

% Prepare data for group high
bfca_high = bfca_cv(high, delay);
av_high = mean(mean(bfca_high,2));
se_high = get_ci95(mean(bfca_high,2)); se_high = se_high(2,:);
% Prepare data for group low
bfca_low = bfca_cv(low,delay);
av_low = mean(mean(bfca_low,2));
se_low = get_ci95(mean(bfca_low,2)); se_low = se_low(2,:);
% Prepare data for bar-graph
bar_dat = [av_high, av_low];
bar_err = [se_high se_low];

%%% Plot %%%

% Colors: orange, blue, grey
colors = {[255 153 85]./255, [85 153 255]./255, [179 179 179]./255};

% Create bar chart
f = figure; hold on

b = bar(bar_dat,'LineStyle','none');
b.FaceColor = 'flat';
b.CData = [colors{1}; colors{2}];
errorbar(bar_dat, bar_err, 'Color', 'k', 'linestyle', 'none');

%%% Format plot, add details %%%

ax = gca;
ax.XLabel.String = 'Visual Imagery Vividness';
ax.YLabel.String = 'Delay-period accuracy [% BFCA]';
ax.XTick = [1 2];
ax.XTickLabel = {'strong','weak'};
ax.XLim = [0.25 2.75];
ax.YLim = [0 22];
ax.Box = 'off';
ax.XLabel.FontSize = 13;
ax.YLabel.FontSize = 13;

