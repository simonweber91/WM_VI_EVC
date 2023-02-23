function bhvr_plot(p)

% function bhvr_plot(bhvr, p)
%
% Plot behavioral data and analyses. Creates the following plots:
% 1. Response distribution and vMMM fit
% 2. Response bias
% 3. Behavioral precision (estimated kappa of the vMMM) for each group
% 4. Other estimated parameters for each group
% 5. Individual vMMM fits for detections, swap errors and guesses
%
% Input:
%   - p: Structure with analysis parameters.
%
% Simon Weber, sweber@bccn-berlin.de, 2021

bhvr_file = fullfile(p.dirs.data, 'analysis', 'all', 'results', 'bhvr.mat');

if ~exist(bhvr_file, 'file'), return; end

load(bhvr_file, 'bhvr')

%% 1. Response distribution and vMMM fit

f1 = figure; hold on;
% Colors: orange, blue, grey
colors = {[255 153 85]./255, [85 153 255]./255, [179 179 179]./255};

% Get relevant variables
resp_err = bhvr.resp_err;
vMMM = bhvr.vMMM;

%%% Plot response distribution %%%

x = linspace(-90,90,40);
hc = histcounts(resp_err(:),40);
b = bar(x, hc);
b.FaceColor = colors{3};
b.EdgeColor = 'none';
b_max = max(hc);

%%% Plot vMMM fit %%%

% Create vMMM traces for plotting
x = linspace(-pi,pi,100);
for i_sub = 1:numel(p.subjects)
    Pt(i_sub,:) = vMMM.r_est(i_sub,1) * MD_vmpdf(x, vMMM.m_est(i_sub,1), vMMM.k_est(i_sub,1));  % detections
    Pnt(i_sub,:) = vMMM.r_est(i_sub,2) * MD_vmpdf(x, vMMM.m_est(i_sub,2), vMMM.k_est(i_sub,2)); % swap errors
    Pg(i_sub,:) = vMMM.r_est(i_sub,3) * MD_unipdf(x, -pi, +pi);                                 % guesses
end
LF_plot = Pt + Pnt + Pg;
LF_av = mean(LF_plot);
LF_ci = get_ci95(LF_plot);
% Scale to match histogram
LF_max = max(LF_av); LF_scale = b_max/LF_max;
LF_av = LF_av.*LF_scale;
LF_ci = LF_ci.*LF_scale;

% Plot
x = linspace(-90,90,100);
fill([x fliplr(x)], [LF_av+LF_ci(1,:), fliplr(LF_av+LF_ci(2,:))], 'k', 'FaceAlpha', 0.15, 'LineStyle', 'none');
plt = plot(x,LF_av,'Linewidth',2,'Color','k');

%%% Format plot, add details %%%

xline(0, '--' , 'Color', 'k');

ax = gca;
ax.XLim = [-90 90];
ax.XTick = [-90 -45 0 45 90];
ax.XTickLabel = {'-90' '-45' '0' '45' '90'};
ax.XLabel.String = 'Response error (°)';
ax.YLim = [0 2000];
ax.YTick = [0 500 1000 1500 2000];
ax.YTickLabel = {'0' '0.25' '0.5' '0.75' '1'};
ax.YLabel.String = 'Probability';
ax.XLabel.FontSize = 13;
ax.YLabel.FontSize = 13;
box off

lnd = legend([b plt], {'response error', 'fitted responses'}, 'Location', 'NorthEast');
lnd.Box = 'off';
lnd.FontSize = 11;


%% 2. Response bias

f2 = figure; hold on;
% Colors: orange, blue, grey
colors = {[255 153 85]./255, [85 153 255]./255, [179 179 179]./255};

% Get relevant variables
bias_av = mean(vMMM.m_est(:,1)); bias_av = rad2deg(bias_av)./2;
bias_ci = get_ci95(vMMM.m_est(:,1)); bias_ci = rad2deg(bias_ci(2))./2;

% Plot
b = barh(0, bias_av, 'linestyle', 'none', 'FaceColor', colors{3});
er = errorbar(bias_av, 0, bias_ci, 'horizontal', 'Color', 'k', 'linestyle', 'none');
b.BarWidth = 1;

%%% Format plot, add details %%%

ax = gca;
ax.XLim = [-2 1];
ax.XTick = [-3 -2 -1 0 1];
ax.XTickLabel = {'-3' '-2' '-1' '0' '1'};
ax.XLabel.String = 'Response bias µ (°)';
ax.YLim = [-0.75 0.75];
ax.YAxis.Visible = 'off';
axis square

%% 3. Behavioral precision (estimated kappa of the vMMM) for each group

f3 = figure; hold on
% Colors: orange, blue, grey
colors = {[255 153 85]./255, [85 153 255]./255, [179 179 179]./255};

% Get relevant variables
high = bhvr.high;
low = bhvr.low;
kappa = vMMM.k_est(:,1);

% Prepare bar data
bar_dat = [mean(kappa(low)) mean(kappa(high))];
bar_err = [get_ci95(kappa(low)) get_ci95(kappa(high))];
bar_err = bar_err(2,:);

% Plot
b = bar(bar_dat,'LineStyle','none');
b.FaceColor = 'flat';
b.CData = [colors{1}; colors{2}];
errorbar(bar_dat, bar_err, 'Color', [0.3 0.3 0.3], 'linestyle', 'none');

%%% Format plot, add details %%%

ax = gca;
ax.XLim = [0.25 2.75];
ax.YLim = [0 10];
ax.XLabel.String = 'Visual Imagery Vividness';
ax.YLabel.String = 'Behavioral precision (𝜅)';
ax.XTick = [1 2];
ax.XTickLabel = {'weak','strong'};
ax.XLabel.FontSize = 13;
ax.YLabel.FontSize = 13;
ax.YTick = [0:2:10];


%% 4. Other estimated parameters for each group

f5 = figure; hold on
% Colors: orange, blue, grey
colors = {[255 153 85]./255, [85 153 255]./255, [179 179 179]./255};

% Get relevant variables
high = bhvr.high;
low = bhvr.low;
r1 = vMMM.r_est(:,1);
r2 = vMMM.r_est(:,2);
r3 = vMMM.r_est(:,3);
k2 = vMMM.k_est(:,2);
m = rad2deg(vMMM.m_est(:,1))./2;

% Prepare bar data
bar_dat = [mean(r1(low)) mean(r1(high));
    mean(r2(low)) mean(r2(high));
    mean(r3(low)) mean(r3(high));
    mean(k2(low)) mean(k2(high));
    mean(m(low)) mean(m(high))];
bar_err = [get_ci95(kappa(low)) get_ci95(kappa(high));
    get_ci95(r2(low)) get_ci95(r2(high));
    get_ci95(r3(low)) get_ci95(r3(high));
    get_ci95(k2(low)) get_ci95(k2(high));
    get_ci95(m(low)) get_ci95(m(high))];
bar_err = bar_err(2:2:size(bar_err,1),:);

% Plot
b = bar(bar_dat, 'grouped', 'BarWidth', 0.95, 'EdgeColor', 'none');
b(1).FaceColor = colors{1};
b(2).FaceColor = colors{2};

% Create error bars
[ngroups, nbars] = size(bar_dat);
groupwidth = min(0.8, nbars/(nbars + 1.5));
err_loc = zeros(nbars, ngroups);
for i = 1:nbars
    err_loc(i,:) = (1:ngroups) - groupwidth/2 + (2*i-1) * groupwidth / (2*nbars);
    errorbar(err_loc(i,:), bar_dat(:,i), bar_err(:,i), 'Color', [0.3 0.3 0.3], 'linestyle', 'none');
end

%%% Format plot, add details %%%

ax = gca;
ax.TickDir = 'out';
ax.XTick = 1:ngroups;
ax.XTickLabels = {'proportion of detections (r1)', 'proportion of swar errors (r2)', ...
    'proportion of guesses (r3)', 'precision of swap errors (k2)', 'response bias (m [°])'};
ax.XLabel.String = 'Behavioral parameters';
ax.YLabel.String = 'vMMM estimate [a.u.]';
ax.XLabel.FontSize = 13;
ax.YLabel.FontSize = 13;
ax.Box = 'off';
lnd = legend({'weak', 'strong'},'Location','NorthWest');
lnd.Box = 'off';


%% Plot individual vMMM fits (detections, swap errors, guesses)

f4 = figure; hold on;
% Colors: green, purple, red
colors = {[0 170 0]./255, [179 128 255]./255, [255 42 42]./255};

% Create vMMM traces for plotting
x = linspace(-pi,pi,100);
for i_sub = 1:numel(p.subjects)
    Pt(i_sub,:) = vMMM.r_est(i_sub,1) * MD_vmpdf(x, vMMM.m_est(i_sub,1), vMMM.k_est(i_sub,1));  % detections
    Pnt(i_sub,:) = vMMM.r_est(i_sub,2) * MD_vmpdf(x, vMMM.m_est(i_sub,2), vMMM.k_est(i_sub,2)); % swap errors
    Pg(i_sub,:) = vMMM.r_est(i_sub,3) * MD_unipdf(x, -pi, +pi);                                 % guesses
end
Pt_av = mean(Pt); Pt_ci = get_ci95(Pt);
Pnt_av = mean(Pnt); Pnt_ci = get_ci95(Pnt);
Pg_av = mean(Pg); Pg_ci = get_ci95(Pg);

% Plot
x = linspace(-90,90,100);
fill([x fliplr(x)], [Pt_av+Pt_ci(1,:), fliplr(Pt_av+Pt_ci(2,:))], colors{1}, 'FaceAlpha', 0.15, 'LineStyle', 'none'); % colors{1}
plt1 = plot(x,Pt_av,'Linewidth',2,'Color',colors{1}); % colors{1}
fill([x fliplr(x)], [Pnt_av+Pnt_ci(1,:), fliplr(Pnt_av+Pnt_ci(2,:))], colors{2}, 'FaceAlpha', 0.15, 'LineStyle', 'none'); % colors{1}
plt2 = plot(x,Pnt_av,'Linewidth',2,'Color',colors{2});
fill([x fliplr(x)], [Pg_av+Pg_ci(1,:), fliplr(Pg_av+Pg_ci(2,:))], colors{3}, 'FaceAlpha', 0.15, 'LineStyle', 'none'); % colors{1}
plt3 = plot(x,Pg_av,'Linewidth',2,'Color',colors{3});

%%% Format plot, add details %%%

xline(0, '--' , 'Color', 'k'); % [0.5 0.5 0.5]

ax = gca;
ax.XLim = [-90 90];
ax.XTick = [-90 -45 0 45 90];
ax.XTickLabel = {'-90' '-45' '0' '45' '90'};
ax.XLabel.String = 'Response error (°)';
ax.YLim = [0 1];
ax.YTick = [0 0.25 0.5 0.75 1];
ax.YTickLabel = {'0' '0.25' '0.5' '0.75' '1'};
ax.YLabel.String = 'Probability';
ax.XLabel.FontSize = 13;
ax.YLabel.FontSize = 13;
box off

lnd = legend([plt1 plt2 plt3], {'detections', 'swap errors', 'guesses'}, 'Location', 'NorthWest');
lnd.Box = 'off';
lnd.FontSize = 11;
