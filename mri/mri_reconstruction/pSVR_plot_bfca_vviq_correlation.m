function pSVR_plot_bfca_vviq_correlation(p)

% Get relevant variables from 'p'
delay = p.psvr.delay;
p.psvr.label = 'target';

%%% Prepare data %%%

% Load VVIQ scores
[vviq_score, high, low] = vviq_scores(p);
vviq = vviq_score';

% Load results of grid-search pSVR analysis
all_results = pSVR_load_results(p, 'grid');
% Run nested cross-validation across subjects to determine optimal values
% for voxel-count and feature-space smoothing fwhm
bfca_cv = pSVR_nested_cv(all_results, p);
% Remove chance level
bfca_cv = bfca_cv-50;
bfca = mean(bfca_cv(:,delay),2);

% Fit multiple linear model and get fit lines using helper figure
mdl = fitlm(vviq, bfca);
[rho, pval] = corr(bfca, vviq);

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
s_h = scatter(vviq(high), bfca(high), 50, colors{1}, 'filled');
s_l = scatter(vviq(low), bfca(low), 50, colors{2}, 'filled');

% Plot regression line
fit_a = plot(fit_line(1,:), fit_line(2,:), 'LineWidth', 3, 'Color', 'k');
ci_a = fill([ci_lower(1,:) fliplr(ci_upper(1,:))], [ci_lower(2,:) fliplr(ci_upper(2,:))], 'k', 'FaceAlpha', 0.15, 'LineStyle', 'none');

% Plot chance level
yline(0, '--' , 'Color', [0.5 0.5 0.5]);

%%% Format plot, add details %%%

ax = gca;
ax.XLabel.String = 'Visual Imagery Vividness Score';
ax.YLabel.String = 'Delay-period accuracy [% BFCA]';
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
ll_a = legend([fit_a, s_h, s_l], {['all, r = ' num2str(round(rho,3)) ', ' pstr], 'strong', 'weak'}, 'Location', 'NorthWest');
ll_a.FontSize = 11;
ll_a.Box = 'off';


