function pp_surfacerender(sub_id, p)

% function pp_surfacerender(sub_id, p)
%
% Creates a 3-D rendered image of the cortical surface based on the white-
% and grey-matter tissue probability maps generated via pp_segment.m
% (prefix 'c'). Rendered images are produced with SPM and converted into
% 3-D printable .stl format with MRIcroS.
%
% Input:
%   - i_sub: ID of the current subject.
%   - p: Structure with analysis parameters.
%
% Simon Weber, sweber@bccn-berlin.de, 2020

addpath('/.../MRIcroS')

% Exptract relevant variables from p
data_dir                = p.dirs.data;
n_ses                   = p.n_session;

% Get subject ID as string
sub_str                 = num2str(sub_id,'%02i');

% Get input images (individual tissue probability maps)
if n_ses > 1
    % Check if output images already exist
    check_file = dir(fullfile(data_dir, 'Nifti', ['sub-' sub_str], 'ses-01', 'anat', '*.surf.gii'));
    tissue = cellstr(spm_select('FPList', fullfile(data_dir, 'Nifti', ['sub-' sub_str], 'ses-01', 'anat'), ['^c.*rsub.*.nii']));
elseif n_ses == 1
    % Check if output images already exist
    check_file = dir(fullfile(data_dir, 'Nifti', ['sub-' sub_str], 'anat', '*.surf.gii'));
    tissue = cellstr(spm_select('FPList', fullfile(data_dir, 'Nifti', ['sub-' sub_str], 'anat'), ['^c.*rsub.*.nii']));
end

% Check if input files are present
if isempty(tissue{1})
    warning('Subject %d - surface render: no input files found.', sub_id);
    return;
end

% Overwrite if requested
if ~isempty(check_file) && p.OVERWRITE == 1
    warning('FILES WILL BE OVERWRITTEN!!! If this was a mistake, abort now!');
    pause(5);
    
    delete(fullfile(check_file(1).folder, '*.surf.gii'));
    delete(fullfile(check_file(1).folder, 'render_c1rsub*'));
    delete(fullfile(check_file(1).folder, '*_surface.stl'));
    check_file = [];
end

% Run
if isempty(check_file)
    
    fprintf('\nSubject %d - perform surface rendering.', sub_id)

    % Use only white- and grey-matter tissue probability maps
    tissue = tissue{[1,2]};

    % Extract surface from white and grey matter
    spm_surf(tissue,3);
    
    if n_ses > 1
        render = dir(fullfile(data_dir, 'Nifti', ['sub-' sub_str], 'ses-01', 'anat', '*.surf.gii'));
    elseif n_ses == 1
        render = dir(fullfile(data_dir, 'Nifti', ['sub-' sub_str], 'anat', '*.surf.gii'));
    end
    
    % Save as .stl file
    MRIcroS('addLayer',fullfile(render.folder, render.name));
    MRIcroS('saveMesh',fullfile(render.folder, ['sub-' sub_str '_surface.stl']));
    close MRIcroS
    
else
    warning('Subject %d - surface render already exist, skip rendering.', sub_id)
end