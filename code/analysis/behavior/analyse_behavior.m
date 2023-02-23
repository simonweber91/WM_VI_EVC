function analyse_behavior(p)

% Analyse the behavioral data of the MRI experiment by fitting a von Mises
% mixture model (vMMM) on the response errors. The main parameter of
% interest is the 'kappa'-parameter, which controls the dispersion of the
% fitted distribution and is therefore a measure of beahvioral precision
% (i.e. how precisely the reports matched the actually presented
% orientation).

% Load behavioral data of the MRI experiment from the logfiles
bhvr = bhvr_load(p);

% Fit a von Mises mixture model (vMMM) using maximum likelihood estimation
% (MLE)
bhvr_analyse(bhvr, p);

% Create various plots
bhvr_plot(p);

