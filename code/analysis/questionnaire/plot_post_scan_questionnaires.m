function plot_post_scan_questionnaires(p)

% Load post-scan questionnaire data
vviq_file = dir(fullfile(p.dirs.data, 'questionnaire', 'post_scan.mat'));
if isempty(vviq_file)
    warning('vviq.mat not found.');
    return;
end
load(fullfile(vviq_file.folder, vviq_file.name), 'post_scan')
vviq_post = post_scan.('VVIQ post');
osiq_visual = post_scan.('OSIQ visual');
osiq_spatial = post_scan.('OSIQ spatial');

% Load recruitment VVIQ scores
[vviq_pre, high, low] = vviq_scores(p);


% Colors: orange, blue, grey
colors = {[255 153 85]./255, [85 153 255]./255, [179 179 179]./255};


%% Plot VVIQ test-retest correlation

% Prepare data
mdl = fitlm(vviq_pre, vviq_post);
[rho, pval] = corr(vviq_pre, vviq_post);

figure;plt = plot(mdl);
fit_line = [plt(2).XData; plt(2).YData];
ci_lower = [plt(3).XData; plt(3).YData];
ci_upper = [plt(4).XData; plt(4).YData];
close;

% Plot
f1 = figure; hold on;

s_l = scatter(vviq_pre(low), vviq_post(low), 50, colors{1}, 'filled');
s_h = scatter(vviq_pre(high), vviq_post(high), 50, colors{2}, 'filled');

fit_a = plot(fit_line(1,:), fit_line(2,:), 'LineWidth', 3, 'Color', 'k');
ci_a = fill([ci_lower(1,:) fliplr(ci_upper(1,:))], [ci_lower(2,:) fliplr(ci_upper(2,:))], 'k', 'FaceAlpha', 0.15, 'LineStyle', 'none');

%%% Format plot, add details %%%
if pval >= 0.001, pstr = ['p = ' num2str(round(pval,3))];
elseif pval < 0.001, pstr = ['p < 0.001'];
end
ll_a = legend([fit_a, s_l, s_h], {['all, r = ' num2str(round(rho,3)) ', ' pstr], 'low', 'high'}, 'Location', 'NorthWest');
ll_a.FontSize = 11;
ll_a.Box = 'off';
ax = gca;
ax.Title.String = '';
ax.XLabel.String = 'recruitment VVIQ score';
ax.YLabel.String = 'post-scan VVIQ score';
ax.XLim = [10 90];
ax.YLim = [10 90];
ax.XLabel.FontSize = 13;
ax.YLabel.FontSize = 13;
ax.Box = 'off';


%% VVIQ post with old groups

f2 = figure; hold on

% Prepare bar data
bar_dat = [mean(vviq_post(low)) mean(vviq_post(high))];
bar_err = [get_ci95(vviq_post(low)) get_ci95(vviq_post(high))];
bar_err = bar_err(2,:);

% Run t-test
[h_post, p_post, ci_post, stats_post] = ttest2(vviq_post(low), vviq_post(high));
% [p_post, h_post, stats_post] = ranksum(vviq_post(low), vviq_post(high));

% Plot
b = bar(bar_dat,'LineStyle','none');
b.FaceColor = 'flat';
b.CData = [colors{1}; colors{2}];

jitter = ones(numel(vviq_post(low)),1)+(randn(numel(vviq_post(low)),1)./75);
scatter(jitter, vviq_post(low), 20, [0.45 0.45 0.45], 'filled')
scatter(jitter+1, vviq_post(high), 20, [0.45 0.45 0.45], 'filled')

errorbar(bar_dat, bar_err, 'Color', [0.3 0.3 0.3], 'linestyle', 'none');

text(1, 80, sprintf('t(%i) = %1.3f, p = %1.3f', stats_post.df, round(stats_post.tstat,3), round(p_post,3)), 'FontSize', 12)

%%% Format plot, add details %%%

ax = gca;
ax.XLim = [0.25 2.75];
ax.YLim = [0 90];
ax.XLabel.String = 'Visual Imagery Vividness';
ax.YLabel.String = 'Post-scan VVIQ scores';
ax.XTick = [1 2];
ax.XTickLabel = {'weak','strong'};
ax.XLabel.FontSize = 13;
ax.YLabel.FontSize = 13;


%% Plot OSIQ data

% Prepare data
bar_dat = [mean(osiq_visual(low)) mean(osiq_visual(high));
    mean(osiq_spatial(low)) mean(osiq_spatial(high))];
bar_err = [get_ci95(osiq_visual(low)) get_ci95(osiq_visual(high));
    get_ci95(osiq_spatial(low)) get_ci95(osiq_spatial(high))];
bar_err = bar_err(2:2:size(bar_err,1),:);

% Run t-tests
[h_vis, p_vis, ci_vis, stats_vis] = ttest2(osiq_visual(low), osiq_visual(high));
[h_spa, p_spa, ci_spa, stats_spa] = ttest2(osiq_spatial(low), osiq_spatial(high));
% [p_vis, h_vis, stats_vis] = ranksum(osiq_visual(low), osiq_visual(high));
% [p_spa, h_spa, stats_spa] = ranksum(osiq_spatial(low), osiq_spatial(high));

% Plot
f3 = figure; hold on;
b = bar(bar_dat, 'grouped', 'BarWidth', 0.95, 'EdgeColor', 'none');
b(1).FaceColor = colors{1};
b(2).FaceColor = colors{2};

% Create error bars
[ngroups, nbars] = size(bar_dat);
groupwidth = min(0.8, nbars/(nbars + 1.5));
err_loc = zeros(nbars, ngroups);
for i = 1:nbars
    err_loc(i,:) = (1:ngroups) - groupwidth/2 + (2*i-1) * groupwidth / (2*nbars);
end

jitter = zeros(numel(osiq_visual(low)),1)+(randn(numel(osiq_visual(low)),1)./75);
scatter(err_loc(1)+jitter, osiq_visual(low), 20, [0.45 0.45 0.45], 'filled')
scatter(err_loc(2)+jitter, osiq_visual(high), 20, [0.45 0.45 0.45], 'filled')
scatter(err_loc(3)+jitter, osiq_spatial(low), 20, [0.45 0.45 0.45], 'filled')
scatter(err_loc(4)+jitter, osiq_spatial(high), 20, [0.45 0.45 0.45], 'filled')

for i = 1:nbars
    errorbar(err_loc(i,:), bar_dat(:,i), bar_err(:,i), 'Color', [0.3 0.3 0.3], 'linestyle', 'none');
end

text(1, 65, sprintf('t(%i) = %1.3f,\np = %1.3f', stats_vis.df, round(stats_vis.tstat,3), round(p_vis,3)), 'FontSize', 12)
text(2, 60, sprintf('t(%i) = %1.3f,\np = %1.3f', stats_spa.df, round(stats_spa.tstat,3), round(p_spa,3)), 'FontSize', 12)

%%% Format plot, add details %%%
ax = gca;
ax.TickDir = 'out';
ax.XTick = 1:ngroups;
ax.XTickLabels = {'visual', 'spatial'};
ax.XLabel.String = 'OSIQ';
ax.YLabel.String = 'Scores';
ax.XLabel.FontSize = 13;
ax.YLabel.FontSize = 13;
% ax.YLim = [0 70];
ax.Box = 'off';
lnd = legend({'weak', 'strong'},'Location','NorthWest');
lnd.Box = 'off';
