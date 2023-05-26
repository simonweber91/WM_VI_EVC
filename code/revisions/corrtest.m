% Script for a power simulation for the detection of correlation effects,
% depending on whether variables are pre-selected or not.

% Size of original sample (i.e., respondents to the VVIQ)
n = 200;
% Size of quartiles
quart = n/4;
% Number of selected samples per group (total is n_sel*2)
n_sel = 20;

sigma = 1;

% Rho values
rhos = 0:0.01:1;

% Number of repetitions
n_reps = 10000;

% Allocate arrays
allH = zeros(1, numel(rhos));
allR = zeros(n_reps, numel(rhos));
allT = zeros(1, numel(rhos));

allH_sel = zeros(1, numel(rhos));
allR_sel = zeros(n_reps, numel(rhos));
allT_sel = zeros(1, numel(rhos));

for i_rho = 1:numel(rhos)

    rho = rhos(i_rho)
    
    for rep = 1:n_reps
        
        % Covariance matrix (the correlation is in here)
        SigmaR = sigma.^2 .* [1 rho; rho 1];
        
        % Sample data from multivariate normal distribution
        ZR = mvnrnd([0 0],SigmaR,n);
        
        % Select 40 random subjects (random as in the first 40)
        ZR_rand = ZR(1:(n_sel*2),:);
        % Correlation for random subjects
        [r, p] = corrcoef(ZR_rand);
        allH(i_rho) = allH(i_rho) + double(p(2) < 0.05);
        allR(rep,i_rho) = r(2);
        
        % Select 20 strong and 20 weak subjects (drawn from upper and lower quartile of ZR(:,1))
        [~, si_sel] = sort(ZR(:,1));
        low = si_sel(randperm(quart,n_sel));
        high = si_sel(randperm(quart,n_sel) + quart*3);
        ZR_sel = ZR([low high],:);
        % Correlation for selected subjects
        [r, p] = corrcoef(ZR_sel);        
        allH_sel(i_rho) = allH_sel(i_rho) + double(p(2) < 0.05);
        allR_sel(rep,i_rho) = r(2);
        
        % Group t-test for random (split half) and selected
        [~, si_rand] = sort(ZR_rand(:,1));
        allT(i_rho) = allT(i_rho) + double(ttest2(ZR(si_rand(1:n_sel),2),ZR(si_rand(n_sel+1:end),2)));
        allT_sel(i_rho) = allT_sel(i_rho) + double(ttest2(ZR_sel(1:n_sel,2),ZR_sel((n_sel+1):end,2)));
        
    end
end

%% Plot simulation results

colors = {[255 153 85]./255, [85 153 255]./255, [179 179 179]./255};

figure;

% 1. Plot probability of detecting a correlation
subplot(2,2,1), hold on,
plot(rhos, allH/n_reps, 'LineWidth', 2, 'Color', colors{1})
plot(rhos, allH_sel/n_reps, 'LineWidth', 2, 'Color', colors{2})
xlabel('true rho')
ylabel('probability of detecting a correlation')
legend('random selection', 'preselection', 'Location', 'southeast', 'Box', 'off')

% 2. Plot mean of recovered rho
subplot(2,2,2), hold on,
% get mean and CI via Fisher z transform
allR_av = tanh(mean(atanh(allR)));
allR_sel_av = tanh(mean(atanh(allR_sel)));
% allR_ci = tanh(get_ci95(atanh(allR))); allR_ci = allR_ci(2,:); allR_ci(end) = allR_ci(end-1);
% allR_sel_ci = tanh(get_ci95(atanh(allR))); allR_sel_ci = allR_sel_ci(2,:); allR_sel_ci(end) = allR_sel_ci(end-1);
% % plot CI
% fill([rhos fliplr(rhos)], [allR_av-allR_ci, fliplr(allR_av+allR_ci)], colors{1}, 'FaceAlpha', 0.15, 'LineStyle', 'none');
% fill([rhos fliplr(rhos)], [allR_sel_av-allR_sel_ci, fliplr(allR_sel_av+allR_sel_ci)], colors{2}, 'FaceAlpha', 0.15, 'LineStyle', 'none');
% % Plot mean
p_rand = plot(rhos, allR_av, 'LineWidth', 2, 'Color', colors{1});
p_sel = plot(rhos, allR_sel_av, 'LineWidth', 2, 'Color', colors{2});
xlabel('true rho')
ylabel('recovered rho')
xlim([0 1]); ylim([0 1])
legend([p_rand, p_sel], {'random selection', 'preselection'}, 'Location', 'southeast', 'Box', 'off')

% 3. Plot probability of estimating a rho of <= -0.256
subplot(2,2,3), hold on,
plot(rhos, sum(allR <= -0.256)./n_reps, 'LineWidth', 2, 'Color', colors{1})
plot(rhos, sum(allR_sel <= -0.256)./n_reps, 'LineWidth', 2, 'Color', colors{2})
xlabel('true rho')
ylabel('probability of estimated rho <= -0.256')
legend('random selection', 'preselection', 'Location', 'northeast', 'Box', 'off')

% 4. Plot probability of detecting a group effect
subplot(2,2,4), hold on,
ds = (2*rhos)./sqrt(1-rhos.^2); % from r = d/sqrt(d^2+4)
plot(ds, allT/n_reps, 'LineWidth', 2, 'Color', colors{1})
plot(ds, allT_sel/n_reps, 'LineWidth', 2, 'Color', colors{2})
xlabel('true Cohen''s d')
ylabel('probability of detecting a group difference via t-test')
legend('split-half of random selection', 'preselection', 'Location', 'southeast', 'Box', 'off')
xlim([0 3])
xticks([0 0.5 1 1.5 2 2.5 3])
