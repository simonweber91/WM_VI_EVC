function vviq_distribution_plot = vviq_plot_distribution(p)

vviq_file = dir(fullfile(p.dirs.data, 'analysis', 'all', 'results', 'vviq.mat'));
if isempty(vviq_file)
    warning('vviq.mat not found.');
    return;
end

load(fullfile(vviq_file.folder, vviq_file.name), 'vviq')

% Get histogram counts
x = 16:2:80;
hc = histcounts(vviq.SCORE,numel(x));

% Find lower quartile
qrtl_lower = quantile(vviq.SCORE,0.25);
lower_ind = find(x < qrtl_lower);

% Find upper quartile
qrtl_upper = quantile(vviq.SCORE,0.75);
upper_ind = find(x > qrtl_upper);

% Find rest of distribution
else_ind = lower_ind(end)+1:upper_ind(1)-1;

% Define colors
colors = {[255 153 85]./255, [85 153 255]./255, [179 179 179]./255};

% Plot
vviq_distribution_plot = figure;
hold on;
for i = 1:3
    if i == 1
        b(i) = bar(x(lower_ind), hc(lower_ind), 'FaceColor', colors{2}, 'EdgeColor', 'none');
    elseif i == 2
        b(i) = bar(x(upper_ind), hc(upper_ind), 'FaceColor', colors{1}, 'EdgeColor', 'none');
    elseif i == 3
        b(i) = bar(x(else_ind), hc(else_ind), 'FaceColor', colors{3}, 'EdgeColor', 'none');
    end
end

% Add labels and legend
xlabel('Visual Imagery Vividness Score');
ylabel('Count');

legend([b(1), b(2)], {'lower quartile: weak imagers', 'upper quartile: strong imagers'}, 'location', 'northwest','box','off')

