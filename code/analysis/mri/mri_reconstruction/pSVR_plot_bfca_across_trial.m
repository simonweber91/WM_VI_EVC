function pSVR_plot_bfca_across_trial(p)

% Get relevant variables from 'p'
labels = p.psvr.all_labels;
delay = p.psvr.delay;

%%% Plot %%%

% Define colors and positions for significance bars
colors = {[0 170 0]./255; [255 85 85]./255; [179 128 255]./255; [255 212 42]./255};
sig_pos = [39 38 37 36];

f = figure;
hold on;

% Plot in reverse order so that target is top layer
for i = numel(labels):-1:1
    
    % Load stats file for current label
    stats_file = dir(fullfile(p.dirs.data, 'analysis', 'all', 'results', ['pSVR_' p.psvr.event '_' labels{i} '_' p.psvr.roi '_stats.mat']));
    if isempty(stats_file)
        warning('No stats file, cannot plot.');
        return;
    end
    load(fullfile(stats_file.folder, stats_file.name), 'tmass_stats')

    % Get relevant variables
    av = tmass_stats.empirical.mean;
    ci = tmass_stats.empirical.ci;
    sig_tp = tmass_stats.sig_tp;

    % Convert TRs to seconds for plotting
    x = [0:numel(av)-1]*0.8;
    
    % Plot CI, accuracy trace and significance bar
    fill([x fliplr(x)], [av-ci, fliplr(av+ci)], colors{i}, 'FaceAlpha', 0.15, 'LineStyle', 'none');
    plt(i).p = plot(x, av,'LineWidth',2.5,'Color',colors{i});
    plot(x, sig_tp*sig_pos(i), 'LineWidth', 2, 'Color', colors{i})

end

% Plot chance level
yline(0, '--' , 'Color', [0.5 0.5 0.5]);

% Plot delay-period marker
fill([x([delay delay(end)+1]) fliplr(x([delay delay(end)+1]))], [repmat(20,1,numel(p.psvr.delay)+1), repmat(23,1,numel(p.psvr.delay)+1)], [215 215 215]./255, 'LineStyle', 'none');
text(7, 21.5, 'delay', 'FontAngle','italic');

% Add text about event onsets
text(0, -2, '|delay', 'FontWeight', 'bold');
text(10, -2, '|probe', 'FontWeight', 'bold'); % 12.5 in TR
text(12.8, -2, '|response', 'FontWeight', 'bold'); % 16 in TR

%%% Format plot, add details %%%

ax = gca;
ax.YLim = [-5 40];
ax.XLim = [0 x(end)];
ax.YLabel.String = 'Accuracy [% BFCA]';
ax.XLabel.String = 'Time [s]';
ax.XLabel.FontSize = 13;
ax.YLabel.FontSize = 13;

% Legend
ll = legend([plt(1).p, plt(4).p , plt(2).p, plt(3).p], {'target ± 95% CI', 'reported ± 95% CI', 'distractor ± 95% CI', 'probe ± 95% CI'}, 'Location', 'northeastoutside');
ll.Box = 'off';
