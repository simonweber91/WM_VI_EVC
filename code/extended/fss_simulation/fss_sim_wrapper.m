
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

p.sim.n_reps = 1000;
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
path = fullfile(data_dir, 'data', 'simulations');
if ~exist(path,'dir'); mkdir(path); end
filename = fullfile(path, ['fss_simulation_' datestr(now,'yymmddHHMMSS') '.mat']);
save(filename, 'bfca', 'p', '-v7.3')


%% Plotting

%%% Prepare data for plotting %%%

% Scale to 1-100 and subtract chance-level
bfca = bfca.*100-50;

% Get BFCA gain compared to no smoothing (FWHM = 0)
bfca_gain = bfca-bfca(1,:,:);

% Get noise condition
noise = permute(bfca(:,1,:),[3 1 2]);

colors = {[0 0.4470 0.7410], [0.8500 0.3250 0.0980], [0.9290 0.6940 0.1250]};


%%% 1. Plot noise across FWHM %%%

figure; hold on;
boxplot(noise, 'PlotStyle', 'compact', 'Colors', colors{1}, 'Symbol', '');

ax = gca;
ax.YLim = [-20 20];
ax.XTick = [0:5:35];
ax.XTickLabel = {'0','50','100','150','200','250','300','350'};

xlabel('FWHM of smoothing kernel (°)'); ylabel('BFCA above chance (%)')

%%% 2. BFCA Surface Plot %%%

% Plot mean BFCA across reps for all parameter combinations
figure;
% s1 = imagesc(fwhm, snr, mean(bfca,3)');
imagesc(mean(bfca,3)');
[h_bounds, p_bounds] = ttest(bfca,0,'Dim',3,'Tail','right');
h_bounds(isnan(h_bounds)) = 0; p_bounds(isnan(p_bounds)) = 1;
% runBoundary(p_bounds<0.05/numel(p_bounds(2:end,:)), 'k', 2);

ax1 = gca;
ax1.YDir = 'normal';

ax1.XTick = [0:5:35];
ax1.XTickLabel = {'0','50','100','150','200','250','300','350'};

ax1.YTickLabel = {'0','0.1','0.2','0.3','0.4','0.5','0.6','0.7','0.8','0.9','1'};

xlabel('FWHM of smoothing kernel (°)'); ylabel('SNR');

c = colorbar;
c.Label.String = 'BFCA above chance (%)';
c.Label.FontSize = 12;


%%% 3. BFCA gained by smoothing Surface Plot %%%

figure;
% s2 = imagesc(fwhm, snr, mean(BFCA_gain,3)');
imagesc(mean(bfca_gain,3)');
[h_bounds, p_bounds] = ttest(bfca_gain,0,'Dim',3,'Tail','right');
h_bounds(isnan(h_bounds)) = 0; p_bounds(isnan(p_bounds)) = 1;
% draw significance bounds of bonferroni corrected p-values (ignore fwhm=0
% condition for correction, as we are not doing a test for that)
b = runBoundary(p_bounds<0.05/numel(p_bounds(2:end,:)), 'k', 4);

ax2 = gca;
ax2.YDir = 'normal';

ax2.XTick = [0:5:35];
ax2.XTickLabel = {'0','50','100','150','200','250','300','350'};

ax2.YTickLabel = {'0','0.1','0.2','0.3','0.4','0.5','0.6','0.7','0.8','0.9','1'};

xlabel('FWHM of smoothing kernel (°)'); ylabel('SNR');

c = colorbar;
c.Label.String = 'BFCA gain (%)';
c.Label.FontSize = 12;

l = legend(b,{'p < 0.05, corrected'}, 'Location', 'NorthEast');

