function [roi_data, roi_mask] = load_fmri(sub_id, p)

roi_data = [];
roi_mask = [];

% Load fMRI data
sub_str = num2str(sub_id,'%02i');
data_dir = fullfile(p.dirs.data, 'analysis', ['sub-' sub_str], 'fmri');
data_file = fullfile(data_dir, ['fmri_' p.psvr.roi '.mat']);

if exist(data_file, 'file')
    % Load ROI data
    load(data_file, 'roi_data', 'roi_mask')
else
    % Load realigned images
    [roi_data, roi_mask] = load_raw_data_masked(p, sub_id);
    if isempty(roi_data)
        warning('Subject %d - no fMRI data available.', sub_id);
        return;
    end
    % Save ROI data
    if ~exist(data_dir,'dir'), mkdir(data_dir); end
    save(data_file, 'roi_data', 'roi_mask', '-v7.3');
end