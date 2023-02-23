function [sin_pred, cos_pred, ang_pred] = pSVR_predict(data_psvr, labels_psvr, mask_psvr, missing, p)

% function [sin_pred, cos_pred, ang_pred] = pSVR_predict(data_psvr, labels_psvr, mask_psvr, missing, p)
%
% Initialize multitarget/periodic support vector regression (pSVR). First,
% labels are transformed into a sinusoid and a cosinusoid that together
% span a periodic space. Second, the data from the brain regions relevant
% for the analysis (i.e. ROIs, searchlights) is extracted. Third,
% multitarget support vector regression is initialized as implemented in
% The Decoding Toolbox (TDT, Hebart, Goergen, et al, 2015), i.e. sine and
% cosine labels are predicted individually. Finally, angular label
% predictions are reconstructed from the predicted sine and cosine labels
% using the four-quadrant inverse tangent inplemented in atan2.m.
%
% Input:
%   - data: 3D array, where the first dimension is trials, second dimension
%       is voxels and third dimension is TRs.
%   - labels: Cell array with sine/cosine labels for pSVR.
%   - mask: Indices of the ROI mask.
%   - missing: Logical array where 1s indicate missing trials.
%   - p: Structure with analysis parameters.
%
% Output:
%   - sin_pred: cell array of predicted sine labels.
%   - cos_pred: cell array of predicted cosine labels.
%   - ang_pred: cell array of predicted angular labels.
%
% Simon Weber, sweber@bccn-berlin.de, 2021

% Prepare TDT variables (needed to create analysis design)
n_run = p.n_session * p.n_run;
chunk = sort(repmat(1:n_run, 1, p.n_trials))';
chunk(missing) = [];

% Initialize cfg and set parameters for multitarget SVR
cfg = decoding_defaults;
cfg.results.overwrite = 1;
cfg.analysis = 'ROI';
cfg.multitarget = 1;
cfg.decoding.method = 'regression';
cfg.decoding.train.classification.model_parameters = '-s 4 -t 2 -c 1 -n 0.5 -b 0 -q';
cfg.decoding.software = 'libsvm_multitarget';
cfg.results.output = {'predicted_labels_multitarget'};
cfg.scale.method = 'min0max1';
cfg.scale.estimation = 'across';
cfg.plot_selected_voxels = 0;
cfg.plot_design = 0;
cfg.results.write = 0;

% Fill passed_data
passed_data.data = data_psvr;
passed_data.dim = p.img.dim;
passed_data.mask_index = mask_psvr;
[passed_data,cfg] = fill_passed_data(passed_data, cfg, labels_psvr, chunk);

% Create design (and plot once if required)
cfg.design = make_design_cv(cfg);
%     if i_tr == 1
%         cfg.fighandles.plot_design = plot_design(cfg);
%     end

% Peform decoding using TDT core function 'decoding.m'
[results, cfg, passed_data] = decoding(cfg, passed_data);

% Extract predictions from TDT results structure
sin_pred = results.predicted_labels_multitarget.output.model{1}.predicted_labels;
cos_pred = results.predicted_labels_multitarget.output.model{2}.predicted_labels;

% Reconstruct predicted angular label using four-quadrant
% arctangent
ang_pred = atan2(sin_pred,cos_pred);
