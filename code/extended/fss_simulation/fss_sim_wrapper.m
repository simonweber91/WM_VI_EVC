
%%% Add analysis scripts and required toolboxes to the search path %%%

addpath('/.../VisualImagery_paper/extended/fss_simulation/');
addpath('/.../VisualImagery_paper/analysis/general_purpose/');

% 1. The Decoding Toolbox (TDT), version 3.999E or higher
% https://sites.google.com/site/tdtdecodingtoolbox/
addpath('/.../tdt_3.999F');
% 2. RDK_vMMM toolbox for estimation of von Mises mixture models
% https://github.com/JoramSoch/RDK_vMMM
addpath('/.../RDK_vMMM');

%%% Create structure with key parameters %%%

p.base_dir = '/...';   

p.sim.n_reps = 250;
p.sim.fwhm = [0:10:360];
p.sim.snr = [0:0.1:1];

p.sim.n_vox = 250;                       % number of voxels
p.sim.n_run = 8;                         % number of runs
p.sim.n_trial = 40;                      % trials per run


%%% Run Simulation %%%

% Get relevant variables
n_fwhm = numel(p.sim.fwhm);
n_snr = numel(p.sim.snr);
total_trials = p.sim.n_run*p.sim.n_trial;                     % total number of trials

% Preallocate result variable
bfca = zeros(n_fwhm, n_snr, p.sim.n_reps);

% Set up parallelization, shuffle rng for each worker
% parallel_pool(30, [], 'rng_shuffle')


% For each repetition...
for i_rep = 1:p.sim.n_reps
% parfor i_rep = 1:p.sim.n_reps

    % Generate data
    [x, Y, E] = fss_sim_generate_data(p.sim.n_vox, total_trials);
    
    % For each SNR level...
    for i_snr = 1:n_snr

        % For each FWHM value...
        for i_fwhm = 1:n_fwhm

            % Display progress
            fprintf('REP: %d/%d - SNR: %d/%d - FWHM: %d/%d - TOTAL: %d/%d \n', i_rep, p.sim.n_reps, i_snr, n_snr, i_fwhm, n_fwhm, (((i_rep-1)*n_snr+i_snr)-1)*n_fwhm+i_fwhm, n_fwhm*n_snr*p.sim.n_reps)

            % Scale data according to SNR and add noise
            Yy = Y .* p.sim.snr(i_snr) + E;
        
            % Create 3D array to allow separate smoothing for each
            % simulated run
            Yr = zeros(p.sim.n_trial, p.sim.n_vox, p.sim.n_run);
            for i = 1:p.sim.n_run, Yr(:,:,i) = Yy(p.sim.n_trial*(i-1)+1:p.sim.n_trial*i,:); end

            % Perform feature-space smoothing
            Yr = feature_space_smoothing(Yr, reshape(rad2deg(x),[],p.sim.n_run), p.sim.fwhm(i_fwhm));

            % Go back to original 2D array
            for i = 1:p.sim.n_run, Yy(p.sim.n_trial*(i-1)+1:p.sim.n_trial*i,:) = Yr(:,:,i); end
            
            % Run pSVR
            xr = fss_sim_pSVR(x, Yy, p.sim.n_run);
                       
            % Quantify precision
            bfca(i_fwhm, i_snr, i_rep) = bal_norm_circ_resp_dev(xr, x);

        end
    end
end

% Save simulation results
path = fullfile(base_dir, 'Results', 'simulations');
if ~exist(path,'dir'); mkdir(path); end
filename = fullfile(path, ['fss_simulation_' datestr(now,'yymmddHHMMSS') '.mat']);
save(filename, 'bfca', 'p', '-v7.3')


%% Plotting

%%% Prepare data for plotting %%%

% Scale to 1-100 and subtract chance-level
bfca = bfca.*100-50;

% Get BFCA gain compared to no smoothing (FWHM = 0)
bfca_gain = bfca-bfca(1,:,:);

% a) Get noise condition
noise = permute(bfca(:,1,:),[3 1 2]);
noise_av = mean(noise);
noise_ci = get_ci95(noise);

% b) Get signal condition, i.e. mean across all SNRs except 0
signal = squeeze(mean(bfca(:,2:end,:),2))';
signal_av = mean(signal);
signal_ci = get_ci95(noise);

% c) Get BFCA gain for noise
noise_gain = permute(bfca_gain(:,1,:),[3 1 2]);
noise_gain_av = mean(noise_gain);
noise_gain_ci = get_ci95(noise_gain);

% d) Get BFCA gain across signal conditions
signal_gain = squeeze(mean(bfca_gain(:,2:end,:),2))';
signal_gain_av = mean(signal_gain);
signal_gain_ci = get_ci95(noise_gain);


%%% 1. BFCA across reps for all parameter combinations %%%

figure;

s1 = imagesc(p.sim.fwhm, p.sim.snr, mean(bfca,3)');
ax1 = gca;
ax1.YDir = 'normal';

xlabel('FWHM of smoothing kernel (??)'); ylabel('SNR');

c = colorbar;
c.Label.String = 'BFCA above chance (%)';
c.Label.FontSize = 12;


%%% 2. Plot noise vs. signal as a function of FWHM %%%

figure; hold on;

fill([p.sim.fwhm, fliplr(p.sim.fwhm)], [noise_av+noise_ci(1,:), fliplr(noise_av+noise_ci(2,:))], 'k', 'FaceAlpha', 0.15, 'LineStyle', 'none');
p1 = plot(p.sim.fwhm, noise_av, 'k', 'LineWidth', 2);

fill([p.sim.fwhm, fliplr(p.sim.fwhm)], [signal_av+signal_ci(1,:), fliplr(signal_av+signal_ci(2,:))], 'g', 'FaceAlpha', 0.15, 'LineStyle', 'none');
p2 = plot(p.sim.fwhm, signal_av, 'g', 'LineWidth', 2);

yline(0, '--' , 'Color', [0.5 0.5 0.5]);

xlabel('FWHM of smoothing kernel (??)'); ylabel('BFCA above chance (%)')
xlim([0 360])

legend([p1,p2], {'noise', 'signal present'}, 'box', 'off')


%%% 3. BFCA gained by smoothing Surface Plot %%%

figure;

s2 = imagesc(p.sim.fwhm, p.sim.snr, mean(bfca_gain,3)');
ax2 = gca;
ax2.YDir = 'normal';

xlabel('FWHM of smoothing kernel (??)'); ylabel('SNR');

c = colorbar;
c.Label.String = 'BFCA gain (%)';
c.Label.FontSize = 12;


%%% 4. Plot noise- vs. signal-gain (compared to no smoothing, FWHM = 0) as a function of FWHM %%

figure; hold on;

fill([p.sim.fwhm, fliplr(p.sim.fwhm)], [noise_gain_av+noise_gain_ci(1,:), fliplr(noise_gain_av+noise_gain_ci(2,:))], 'k', 'FaceAlpha', 0.15, 'LineStyle', 'none');
p1 = plot(p.sim.fwhm, noise_gain_av, 'k', 'LineWidth', 2);

fill([p.sim.fwhm, fliplr(p.sim.fwhm)], [signal_gain_av+signal_gain_ci(1,:), fliplr(signal_gain_av+signal_gain_ci(2,:))], 'g', 'FaceAlpha', 0.15, 'LineStyle', 'none');
p2 = plot(p.sim.fwhm, signal_gain_av, 'g', 'LineWidth', 2);

yline(0, '--' , 'Color', [0.5 0.5 0.5]);

xlabel('FWHM of smoothing kernel (??)'); ylabel('BFCA gain (%)')
xlim([0 360])

legend([p1,p2], {'noise', 'signal present'}, 'box', 'off')


