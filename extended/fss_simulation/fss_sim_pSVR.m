function xr = fss_sim_pSVR(x, Y, r)

% Prepare multitarget labels
x_sin = sin(x-pi);
x_cos = cos(x-pi);
label = mat2cell([x_sin, x_cos], ones(numel(x),1));

% Define TDT variables
chunk = sort(repmat(1:r,1,numel(x)/r))';
passed_data = [];
results = [];

% Set up cfg
cfg = decoding_defaults;
cfg.analysis = 'wholebrain';
cfg.decoding.method = 'regression';
cfg.decoding.train.classification.model_parameters = '-s 4 -t 2 -c 1 -n 0.5 -b 0 -q';
cfg.plot_selected_voxels = 0;
cfg.plot_design = 0;
cfg.multitarget = 1;
cfg.decoding.software = 'libsvm_multitarget';
cfg.results.output = {'predicted_labels_multitarget'};
cfg.results.overwrite = 1;
cfg.results.write = 0;
cfg.scale.method = 'min0max1';
cfg.scale.estimation = 'across';

% Fill passed_data and generate design matrix
passed_data.data = Y;
[passed_data,cfg] = fill_passed_data(passed_data,cfg,label,chunk);
cfg.design = make_design_cv(cfg);

% Perform reconstruction
[results,cfg,passed_data] = decoding(cfg,passed_data);

% Reconstruct angular label
xr_sin = results.predicted_labels_multitarget.output.model{1}.predicted_labels;
xr_cos = results.predicted_labels_multitarget.output.model{2}.predicted_labels;

xr = atan2(xr_sin, xr_cos) + pi;

