
% Script to calculate the split-half reliability of the BFCA as a neural
% measure.


delay = p.psvr.delay;
% delay = 12;
p.psvr.label = 'target';

all_results = pSVR_load_results(p, 'grid');
[bfca_cv, voxel_cv, fwhm_cv] = pSVR_nested_cv(all_results, p);

n_perm = 1000;

% Run analysis
for i_sub = 1:numel(p.subjects)
% parallel_pool(p.par.n_workers);

    % Get subject ID
    sub_id = p.subjects(i_sub);

    % Load predictions
    filename = get_filename(sub_id, p);
    filename = dir([filename, '_grid_2*.mat']);
    filename = fullfile(filename.folder, filename.name);
    load(filename, 'predictions')

    % Load labels
    labels = load_labels(sub_id, p, 'sorted', 'includenans');
    [labels_psvr, labels_rad, missing] = pSVR_prepare_labels(labels);

    ang_pred = predictions.ang_pred(voxel_cv(1,i_sub), delay, fwhm_cv(1,i_sub));

    n_trials = numel(labels_rad);

    for i_perm = 1:n_perm

        split_ind = zeros(n_trials,1);
        split_ind(randperm(n_trials,floor(n_trials/2))) = 1;
    
        for i_tr = 1:size(ang_pred,2)
    
            data_split1 = ang_pred{i_tr}(find(split_ind));
            data_split2 = ang_pred{i_tr}(find(~split_ind));
    
            label_split1 = labels_rad(find(split_ind));
            label_split2 = labels_rad(find(~split_ind));
    
            bfca_split1_temp(i_tr) = bal_norm_circ_resp_dev(data_split1, label_split1, 'trapz') .* 100;
            bfca_split2_temp(i_tr) = bal_norm_circ_resp_dev(data_split2, label_split2, 'trapz') .* 100;
    
        end
    
        bfca_split1(i_sub,i_perm) = mean(bfca_split1_temp);
        bfca_split2(i_sub,i_perm) = mean(bfca_split2_temp);
    end

end

[rho, pval] = corr(bfca_split1,bfca_split2);
reliability = tanh(mean(atanh(diag(rho))));


%% Plot 

mdl = fitlm(bfca_split1, bfca_split2);
[rho, pval] = corr(bfca_split1, bfca_split2);

figure;plt = plot(mdl);
fit_line = [plt(2).XData; plt(2).YData];
ci_lower = [plt(3).XData; plt(3).YData];
ci_upper = [plt(4).XData; plt(4).YData];
close;

s = scatter(bfca_split1, bfca_split2, 50, 'Color', [0.45 0.45 0.45], 'filled');

% Plot regression line
fit_a = plot(fit_line(1,:), fit_line(2,:), 'LineWidth', 3, 'Color', 'k');
ci_a = fill([ci_lower(1,:) fliplr(ci_upper(1,:))], [ci_lower(2,:) fliplr(ci_upper(2,:))], 'k', 'FaceAlpha', 0.15, 'LineStyle', 'none');

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
ll_a = legend([fit_a], {['all, r = ' num2str(round(rho,3)) ', ' pstr]}, 'Location', 'NorthWest');
ll_a.FontSize = 11;
ll_a.Box = 'off';