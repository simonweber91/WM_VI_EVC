function analyse_questionnaire(p)

% Load the data of the Vividness of Visual Imagery questionnaire (Marks,
% 1975) used for recruitment and plot the distribution of VVIQ scores. The
% upper and lower quartile of the distribution (marked in the plot) where
% used as recruitment pools for the strong and weak imagery groups,
% respectively, for the MRI experiment.

% Load VVIQ data used for recruitment
vviq = vviq_load(p);

% Plot the distribution of the questionnaire VVIQ scores
vviq_plot_distribution(vviq);
