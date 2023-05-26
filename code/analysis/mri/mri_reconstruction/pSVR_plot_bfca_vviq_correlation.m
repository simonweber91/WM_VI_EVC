function pSVR_plot_bfca_vviq_correlation(p)

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
[vviq, high, low] = vviq_scores(p);
if isempty(vviq)
    warning('No vviq data, cannot plot.');
    return;
end

bfca = mean(bfca_cv(:,delay),2);

% Fit multiple linear model and get fit lines using helper figure
mdl = fitlm(vviq, bfca);
[rho, pval] = corr(bfca, vviq);

figure;plt = plot(mdl);
fit_line = [plt(2).XData; plt(2).YData];
ci_lower = [plt(3).XData; plt(3).YData];
ci_upper = [plt(4).XData; plt(4).YData];
close;

% Run t-test for aphantasia
[h_aph, p_aph, ci_aph, stats_aph] = ttest(bfca(vviq<=32));

%%% Plot %%%

% Colors: orange, blue, grey
colors = {[255 153 85]./255, [85 153 255]./255, [179 179 179]./255};

f1 = figure; hold on;

% Plot scatter
s_l = scatter(vviq(low), bfca(low), 50, colors{1}, 'filled');
s_h = scatter(vviq(high), bfca(high), 50, colors{2}, 'filled');

% Plot regression line
fit_a = plot(fit_line(1,:), fit_line(2,:), 'LineWidth', 3, 'Color', 'k');
ci_a = fill([ci_lower(1,:) fliplr(ci_upper(1,:))], [ci_lower(2,:) fliplr(ci_upper(2,:))], 'k', 'FaceAlpha', 0.15, 'LineStyle', 'none');

% Plot chance level
yline(0, '--' , 'Color', [0.5 0.5 0.5]);

% Plot aphantasia
aph = fill([10, 32, 32, 10], [-5, -5, -1, -1], 'k', 'FaceAlpha', 0.15, 'LineStyle', 'none');
text(11, -3, sprintf('aphantasia,\nt(%i) = %1.3f, p = %1.4f', stats_aph.df, round(stats_aph.tstat,3), round(p_aph,4)), 'FontSize', 8)

%%% Format plot, add details %%%

ax = gca;
ax.XLabel.String = 'Visual Imagery Vividness Score';
ax.YLabel.String = 'Delay-period accuracy [% BFCA above chance]';
ax.XLim = [10 80];
ax.YLim = [-5 45];
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


