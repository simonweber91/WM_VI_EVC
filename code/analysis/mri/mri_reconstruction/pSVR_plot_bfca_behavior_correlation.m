function pSVR_plot_bfca_behavior_correlation(p)

%% Plot bfca-behavior correaltion for all subjects

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
if isempty(vviq_score)
    warning('No vviq data, cannot plot.');
    return;
end
vviq = vviq_score';

bfca = mean(bfca_cv(:,delay),2);

load(fullfile(p.dirs.data, 'analysis', 'all', 'results', 'bhvr.mat'), 'bhvr');
behavior = bhvr.vMMM.k_est(:,1);

% Fit multiple linear model and get fit lines using helper figure
mdl = fitlm(behavior, bfca);
[rho, pval] = corr(bfca, behavior);

figure;plt = plot(mdl);
fit_line = [plt(2).XData; plt(2).YData];
ci_lower = [plt(3).XData; plt(3).YData];
ci_upper = [plt(4).XData; plt(4).YData];
close;


%%% Plot %%%

% Colors: orange, blue, grey
colors = {[255 153 85]./255, [85 153 255]./255, [179 179 179]./255};

f1 = figure; hold on;

% Plot scatter
s_l = scatter(behavior(low), bfca(low), 50, colors{1}, 'filled');
s_h = scatter(behavior(high), bfca(high), 50, colors{2}, 'filled');

% Plot regression line
fit_a = plot(fit_line(1,:), fit_line(2,:), 'LineWidth', 3, 'Color', 'k');
ci_a = fill([ci_lower(1,:) fliplr(ci_upper(1,:))], [ci_lower(2,:) fliplr(ci_upper(2,:))], 'k', 'FaceAlpha', 0.15, 'LineStyle', 'none');

% Plot chance level
yline(0, '--' , 'Color', [0.5 0.5 0.5]);

%%% Format plot, add details %%%

ax = gca;
ax.XLabel.String = 'Behavioral precision (𝜅)';
ax.YLabel.String = 'Delay-period accuracy [% BFCA above chance]';
ax.XLim = [1 14];
ax.YLim = [-10 45];
ax.YTick = [-10 0 10 20 30 40];
ax.XLabel.FontSize = 13;
ax.YLabel.FontSize = 13;
ax.Box = 'off';

% Get p-value for legend text
if pval >= 0.001, pstr = ['p = ' num2str(round(pval,3))];
elseif pval < 0.001, pstr = ['p < 0.001'];
end
% Add legend
ll_a = legend([fit_a, s_l, s_h], {['all, r = ' num2str(round(rho,3)) ', ' pstr], 'weak', 'strong'}, 'Location', 'NorthWest');
ll_a.FontSize = 11;
ll_a.Box = 'off';


%% Plot bfca-behavior correaltion for imagery groups

% Fit multiple linear model for each group and get fit lines using helper figure
mdl_h = fitlm(behavior(high), bfca(high)); [rho_h, pval_h] = corr(behavior(high), bfca(high));
mdl_l = fitlm(behavior(low), bfca(low)); [rho_l, pval_l] = corr(behavior(low), bfca(low));

figure; plt_h = plot(mdl_h);
fit_line_h = [plt_h(2).XData; plt_h(2).YData];
ci_lower_h = [plt_h(3).XData; plt_h(3).YData];
ci_upper_h = [plt_h(4).XData; plt_h(4).YData];
close;
figure; plt_l = plot(mdl_l);
fit_line_l = [plt_l(2).XData; plt_l(2).YData];
ci_lower_l = [plt_l(3).XData; plt_l(3).YData];
ci_upper_l = [plt_l(4).XData; plt_l(4).YData];
close;


%%% Plot %%%

f2 = figure; hold on;

% Plot scatter
s_l = scatter(behavior(low), bfca(low), 50, colors{1}, 'filled');
s_h = scatter(behavior(high), bfca(high), 50, colors{2}, 'filled');

% Plot regression lines
fit_l = plot(fit_line_l(1,:), fit_line_l(2,:), 'LineWidth', 3, 'Color', colors{1});
ci_l = fill([ci_lower_l(1,:) fliplr(ci_upper_l(1,:))], [ci_lower_l(2,:) fliplr(ci_upper_l(2,:))], colors{1}, 'FaceAlpha', 0.15, 'LineStyle', 'none');
fit_h = plot(fit_line_h(1,:), fit_line_h(2,:), 'LineWidth', 3, 'Color', colors{2});
ci_h = fill([ci_lower_h(1,:) fliplr(ci_upper_h(1,:))], [ci_lower_h(2,:) fliplr(ci_upper_h(2,:))], colors{2}, 'FaceAlpha', 0.15, 'LineStyle', 'none');

% Plot chance level
yline(0, '--' , 'Color', [0.5 0.5 0.5]);

%%% Format plot, add details %%%

ax = gca;
ax.XLabel.String = 'Behavioral precision (𝜅)';
ax.YLabel.String = 'Delay-period accuracy [% BFCA above chance]';
ax.XLim = [1 14];
ax.YLim = [-10 45];
ax.YTick = [-10 0 10 20 30 40];
ax.XLabel.FontSize = 13;
ax.YLabel.FontSize = 13;
ax.Box = 'off';

% Get p-value for legend text
if pval_l >= 0.001, pstr_l = ['p = ' num2str(round(pval_l,3))];
elseif pval_l < 0.001, pstr_l = ['p < 0.001'];
end
if pval_h >= 0.001, pstr_h = ['p = ' num2str(round(pval_h,3))];
elseif pval_h < 0.001, pstr_h = ['p < 0.001'];
end
% Add legend
ll_g = legend([fit_l fit_h], {['weak, r = ' num2str(round(rho_l,3)) ', ' pstr_l],['strong, r = ' num2str(round(rho_h,3)) ', ' pstr_h]}, 'Location','NorthWest');
ll_g.FontSize = 11;
ll_g.Box = 'off';



