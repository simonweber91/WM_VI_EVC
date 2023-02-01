function bhvr = bhvr_analyse(bhvr, p)

% function bhvr = bhvr_analyse(bhvr, p)
%
% Runs an analysis on the behavioral data of the MRI experiment, by fitting
% a von Mises mixture model (vMMM) to the distribution of the response
% errors. The vMMM consists of 3 components: detections (response to the
% target), swap errors (response to the distractor) and guesses. The
% estimated parameters include 'r_est' (how much each of the 3 components
% contributes to the fit), 'm_est' (the bias of the fit) and 'k_est'
% (kappa, the dispersion of the fit and a measure of behavioral precision).
% The best fit is found using maximum likelyhood estimation, implemented by
% using adapted routines by Joram Soch, BCCN Berlin. The original routines
% are part of the 'RDK_vMMM' toolbox, which can be found at
% "https://github.com/JoramSoch/RDK_vMMM/tree/master/tools/vMMM".
%
% Input:
%   - bhvr: Structure with all relevant behavioral variables.
%   - p: Structure with analysis parameters.
%
% Output:
%   - bhvr: Structure with behavioral variables, with estimated von Mises
%       mixture model (vMMM) parameters added to the structure.
%
% Simon Weber, sweber@bccn-berlin.de, 2021

% Get relevant behavioral variables
resp = bhvr.resp;
target = bhvr.target;
distr = bhvr.distr;

% Get number of subjects
n_sub = numel(p.subjects);

% Initialize result and output variables
r_est = zeros(n_sub, 3);
m_est = zeros(n_sub, 2);
k_est = zeros(n_sub, 2);
MLL = zeros(n_sub, 1);
LF = cell(n_sub, 1);

% Estimate MLL parameters
for i_sub = 1:n_sub
    
    fprintf('- Subject %d -\n ', i_sub);
    
    %%% vMMM %%%
    R = bhvr_preproc(resp(:,i_sub));
    T = bhvr_preproc(target(:,i_sub));
    D = bhvr_preproc(distr(:,i_sub));
    
    E  = R-T; E = mod(E + pi, 2*pi) - pi;       % Response error
    SE = R-D; SE = mod(SE + pi, 2*pi) - pi;     % Swap error

    % vMMM via maximum likelihood estimation
    [r_est(i_sub,:), m_est(i_sub,:), k_est(i_sub,:), MLL(i_sub,:), LF{i_sub}] = bhvr_ML(E, SE, [], [], 'm11');
    
end

% Assign output variables
vMMM.r_est = r_est; vMMM.m_est = m_est; vMMM.k_est = k_est; vMMM.MLL = MLL; vMMM.LF = LF;
bhvr.vMMM = vMMM;

% Save analysis results
out_dir = fullfile(p.base_dir, 'Results', 'behavior');
if ~exist(out_dir,'dir'), mkdir(out_dir); end
out_file = fullfile(out_dir, 'bhvr.mat');
save(out_file, 'bhvr', 'p');
