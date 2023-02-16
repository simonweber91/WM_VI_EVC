
%%% Add analysis scripts and required toolboxes to the search path %%%

% Analysis scripts
addpath('/.../VisualImagery_paper/extended/eye/');
addpath(genpath('/.../VisualImagery_paper/analysis/'));

% Toolboxes
% 1. SPM12
% https://www.fil.ion.ucl.ac.uk/spm/software/download/
addpath('/.../spm12/');
% 2. The Decoding Toolbox (TDT), version 3.999E or higher
% https://sites.google.com/site/tdtdecodingtoolbox/
addpath('/.../tdt_3.999F');
% 3. Fieldtrip
% https://www.fieldtriptoolbox.org/download/
addpath('/.../fieldtrip-20190205/');
% 4. Eye tracking analysis tools by Anne Urai:
% https://github.com/anne-urai/Tools/tree/master/eye
addpath('/.../Tools/eye/');

%%
%%% Create structure with key analysis parameters %%%

ft_defaults;

p.base_dir                = '/analysis/sweber/projects/visimg';
p.n_session               = 2;
p.n_run                   = 4;
p.n_trials                = 40;

% Subject IDs
p.subjects = [3 4 5 6 7 8 9 10 11 12 14 15 17 18 19 20 21 23 29 30 31 34 ...
                                35 36 40 41];                              % Subject IDs (i.e. number for the subject-specific BIDS directory)

p.img.filter            = 'task-vwm';
p.img.dim               = [1 2 1];

p.eye.hz                = 1000;
p.eye.seconds           = 15;
p.eye.ds_factor         = 10;   % downsampling factor
p.eye.skip              = false;

p.psvr.label            = 'target';
p.psvr.n_perm           = 1000;                                             % Number of permutations for the permutation analysis

% p.par.n_workers         = 30;                                             % Number of parallel workers 

%%
%%% Run analysis %%%

for i_sub = 1:numel(p.subjects)
% parallel_pool(p.par.n_workers);

    % Get subject ID
    sub_id = p.subjects(i_sub);
    
    % Preprocessing of eyelink data
    [eye, p] = eye_pp(sub_id, p);
    % Check if skipping criteria are fulfilled
    if p.eye.skip, continue; end
    mask = ones(1,size(eye,2));

    % Get subject ID as string
    sub_str = num2str(sub_id,'%02i');

    %-- Load and prepare data for reconstruction --%
    
    % Load labels
    [log, ~ ,exp_struct] = load_log(sub_id, p);
    labels = extract_labels(log, exp_struct, p, 'sorted', 'includenans');
    % Prepare labels for pSVR analysis and reconstruction
    [labels_psvr, labels_rad, missing] = pSVR_prepare_labels(labels);

    % Prepare data for pSVR analysis
    [data_psvr, mask_psvr] = pSVR_prepare_data(eye, mask, size(eye,2), 0, labels);


    %-- 1. Reconstruction of empirical labels --%

    predictions = []; results = [];
    for i_tr = 1:size(eye,4)
    % parfor i_tr = first_tr:p.psvr.n_tr
        
        % Run pSVR
        [sin_pred, cos_pred, ang_pred] = pSVR_predict(data_psvr(:,:,i_tr), labels_psvr, mask_psvr, missing, p);

        % Assign predictions
        predictions.sin_pred{i_tr} = sin_pred;
        predictions.cos_pred{i_tr} = cos_pred;
        predictions.ang_pred{i_tr} = ang_pred;
        % Calculate balanced feature-continuous accuracy
        results.bfca(i_tr) = bal_norm_circ_resp_dev(ang_pred, labels_rad, 'trapz') .* 100;

    end

    % Save recosntruction results
    file_dir = fullfile(p.base_dir, 'Nifti', ['sub-' sub_str], 'predictions', 'eye');
    if ~exist(file_dir,'dir'), mkdir(file_dir); end
    name = ['eye_' p.pred.label '_' datestr(now,'yymmddHHMM') '.mat'];
    out_file = fullfile(file_dir, name);
    save(out_file, 'p', 'predictions', 'results', '-v7.3');

    %-- 2. Permutation analysis --%

    predictions = []; results = [];
    for i_perm = 1:p.psvr.n_perm

        % Permute labels
        perm_ind = randperm(numel(labels_psvr));
        labels_psvr_perm = labels_psvr(perm_ind);
        labels_rad_perm = labels_rad(perm_ind);

        for i_tr = 1:size(eye,4)
        % parfor i_tr = first_tr:p.psvr.n_tr

            fprintf('Analysing: subject %d/%d - permutation %d/%d - TR %d/%d ... \n', sub_id, numel(p.subjects), i_perm, p.psvr.n_perm, i_tr, size(eye,4))
            
            % Run pSVR
            [sin_pred, cos_pred, ang_pred] = pSVR_predict(data_psvr(:,:,i_tr), labels_psvr_perm, mask_psvr, missing, p);

            % Assign predictions
            predictions.sin_pred{i_perm, i_tr} = sin_pred;
            predictions.cos_pred{i_perm, i_tr} = cos_pred;
            predictions.ang_pred{i_perm, i_tr} = ang_pred;
            % Calculate balanced feature-continuous accuracy
            results.bfca(i_perm, i_tr) = bal_norm_circ_resp_dev(ang_pred, labels_rad_perm, 'trapz') .* 100;

        end
    end
    
    % Save permutation results
    name = ['eye_' p.pred.label '_permute_' datestr(now,'yymmddHHMM') '.mat'];
    out_file = fullfile(file_dir, name);
    save(out_file, 'p', 'predictions', 'results', '-v7.3');
    
end

%% 
%%% Calculate cluster t-mass statistic %%%

bfca = zeros(numel(p.subjects), p.eye.hz * p.eye.seconds / p.eye.ds_factor, p.psvr.n_perm + 1);
for i_sub = 1:numel(p.subjects)

    % Get subject ID
    sub_id = p.subjects(i_sub);
    
    % Load data
    sub_str = num2str(sub_id,'%02i');
    file_dir = fullfile(p.base_dir,'Nifti',['sub-' sub_str],'predictions','eye');

    filename = dir(fullfile(file_dir, ['eye_' p.pred.label '_2*.mat']));
    if isempty(filename), continue; end
    load(fullfile(filename.folder, filename.name), 'results');

    bfca(i_sub,:,1) = results.bfca;

    filename = dir(fullfile(file_dir, ['eye_' p.pred.label '_permute_2*.mat']));
    load(fullfile(filename.folder, filename.name), 'results');

    bfca(i_sub,:,2:end) = permute(results.bal_acc,[3 2 1]);
    
end

% Remove chance-level and smooth
bfca = bfca - 50;
bfca = permute(moving_average(permute(bfca,[2 1 3]),10,1),[2 1 3]);

% Stats for all subjects

tmass_stats = cluster_t_mass(bfca, 'right');
% Save stats
out_dir = fullfile(p.base_dir, 'Results', 'eye');
if ~exist(out_dir,'dir'), mkdir(out_dir); end
out_file = fullfile(out_dir, ['eye_' p.psvr.label '_stats']);
save(out_file, 'tmass_stats')

% Stats for high/low imagery groups separately

[~, high, low] = vviq_scores(p);

tmass_stats = cluster_t_mass(bfca(high,:,:), 'right');
out_file = fullfile(out_dir, ['eye_' p.psvr.label '_high_stats']);
save(out_file, 'tmass_stats')

tmass_stats = cluster_t_mass(bfca(low,:,:), 'right');
out_file = fullfile(out_dir, ['eye_' p.psvr.label '_low_stats']);
save(out_file, 'tmass_stats')


%%
%%% Plot results for all subjects %%%

% Colors: orange, blue, grey
colors = {[255 153 85]./255, [85 153 255]./255, [179 179 179]./255};


out_dir = fullfile(p.base_dir, 'Results', 'eye');
load(fullfile(out_dir, ['eye_' p.psvr.label '_stats']));

x = [0:numel(tmass_stats.empirical.mean)-1]*(1/100);

av = tmass_stats.empirical.mean;
ci = tmass_stats.empirical.ci;
sig = tmass_stats.sig_tp;

f = figure; hold on;

fill([x fliplr(x)], [av-ci, fliplr(av+ci)], 'k', 'FaceAlpha', 0.15, 'LineStyle', 'none');
p1 = plot(x, av, 'LineWidth', 2.5, 'Color', 'k');

plot(x, sig+4, 'LineWidth', 2, 'Color', 'k')
yline(0, '--' , 'Color', colors{3});

ylim([-4 6])
xlim([0 x(end)])

ylabel('Accuracy [BFCA]')
xlabel('Time [s]')

text(0, -3, '|s1', 'FontWeight', 'bold');
text(0.8, -3, '|s2', 'FontWeight', 'bold');
text(2, -3, '|delay', 'FontWeight', 'bold');
text(12, -3, '|probe', 'FontWeight', 'bold');

ll = legend(p1, {'all subjects'}, 'Location', 'NorthWest'); ll.Box = 'off';

%%
%%% Plot results for both groups separately %%%

f = figure; hold on;

for i = 2:-1:1
    
    if i == 1, load(fullfile(out_dir, ['eye_' p.psvr.label '_high_stats']), 'tmass_stats');
    elseif i == 2, load(fullfile(out_dir, ['eye_' p.psvr.label '_low_stats']), 'tmass_stats');
    end

    x = [0:numel(tmass_stats.empirical.mean)-1]*(1/100);

    av = tmass_stats.empirical.mean;
    ci = tmass_stats.empirical.ci;
    sig = tmass_stats.sig_tp;

    fill([x fliplr(x)], [av-ci, fliplr(av+ci)], colors{i}, 'FaceAlpha', 0.15, 'LineStyle', 'none');
    plt(i).p = plot(x, av, 'LineWidth', 2.5, 'Color', colors{i});
    plt(i).s = plot(x, sig+3+0.25*(i-1), 'LineWidth', 2, 'Color', colors{i});
    
end

yline(0, '--' , 'Color', [0.5 0.5 0.5]);
ylim([-4 6])
xlim([0 x(end)])
ylabel('Accuracy [BFCA]')
xlabel('Time [s]')

text(0, -3, '|s1', 'FontWeight', 'bold');
text(0.8, -3, '|s2', 'FontWeight', 'bold');
text(2, -3, '|delay', 'FontWeight', 'bold');
text(12, -3, '|probe', 'FontWeight', 'bold');

ll = legend([plt(1).p plt(2).p], {'strong','weak'}, 'Location', 'NorthWest'); ll.Box = 'off';
