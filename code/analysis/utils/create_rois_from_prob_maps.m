function create_rois_from_prob_maps(p, roi_name)

% function create_rois_from_prob_maps(p, roi_name)
%
% Creates binary region of interest (ROI) masks from probability maps
% published by Wang et al (2015). The set of probability maps can be
% downloaded from:
% http://scholar.princeton.edu/sites/default/files/napl/files/probatlas_v4.zip
% The folder 'ProbAtlas_v4' should be stored in a folder 'Rois' in the main
% project directory.
%
% Input: 
%   - p: Structure with analysis parameters, including base directory of
%       the project.
%   - roi_name: Name of the ROI to create. The indices of the probability
%       maps needed to create the requested ROI need to be defined whithin
%       this function, using a 'switch' statement (see
%       'ROIfiles_Labeling.txt' in 'ProbAtlas_v4' for map indices).
%
% Simon Weber, sweber@bccn-berlin.de, 2021

in_dir = fullfile(p.dirs.data, 'Nifti', 'all', 'rois', 'ProbAtlas_v4', 'subj_vol_all');
if ~exist(in_dir,'dir')
    warning('Cannot find probability atlas to create ROIs. Please store ''ProbAtlas_v4'' in ''%s''', fullfile(p.dirs.data, 'Nifti', 'all', 'rois'));
    return;
end

out_dir = fullfile(p.dirs.data, 'Nifti', 'all', 'rois');

if exist(fullfile(out_dir, [roi_name '.nii']), 'file') && ~p.OVERWRITE
    warning('%s already exists.', fullfile(out_dir, [roi_name '.nii']));
    return;
end


switch roi_name
    case 'V1-3'
        maps = [1:6];
    case 'V1'
        maps = [1:2];
    case 'V2'
        maps = [3:4];
    case 'V3'
        maps = [5:6];
end


for i_roi = maps
    
    % Load probability maps for left and right hemispheres
    vol_lh = spm_vol(fullfile(in_dir,['perc_VTPM_vol_roi' num2str(i_roi) '_lh.nii']));
    img_lh = spm_read_vols(vol_lh);
    
    vol_rh = spm_vol(fullfile(in_dir,['perc_VTPM_vol_roi' num2str(i_roi) '_rh.nii']));
    img_rh = spm_read_vols(vol_rh);
    
    % Combine hemispheres
    img_bh = img_lh + img_rh;     
    
    % Assemble ROI
    if i_roi == maps(1)
        roi_img = img_bh;
    else
        roi_img = roi_img + img_bh;
    end
    
end
    
% Scale to 1
roi_img(roi_img>100) = 100;     % max 100% probability
roi_img = roi_img./100;         % scale to 1

% Build header
roi_vol = vol_lh;
roi_vol.fname = fullfile(out_dir, [roi_name '.nii']);
roi_vol.dt = [64 0];    % change datatype to float64

% Write
spm_write_vol(roi_vol, roi_img);

