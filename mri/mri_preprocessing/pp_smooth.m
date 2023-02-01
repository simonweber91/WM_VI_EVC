function model = pp_smooth(sub_id, p)

% function model = pp_smooth(sub_id, p)
%
% Runs SPM smoothing on fMRI images that has been realigned, slice-time
% corrected and normalized (prefix 'war').
%
% Input:
%   - i_sub: ID of the current subject.
%   - p: Structure with analysis parameters.
%
% Output:
%   - model: Structure with all SPM settings used for this preprocessing
%       step (would be 'matlabbatch' in SPM).
%
% Simon Weber, sweber@bccn-berlin.de, 2020

% Exptract relevant variables from p
base_dir                = p.base_dir;
n_ses                   = p.n_session;
filter                  = p.img.filter;
p.pp.fwhm               = [8 8 8];
fwhm                    = p.pp.fwhm;

% Get subject ID as string
sub_str                 = num2str(sub_id,'%02i');

% initialize output variable
model = {};

% Get input images (realigned, slice-time corrected, normalized fMRI
% images)
files = {};
if n_ses > 1
    % Check if output images already exist
    check_file = dir(fullfile(base_dir, 'Nifti', ['sub-' sub_str], 'ses-01', 'func', ['swarsub*' filter '*']));
    for i_ses = 1:n_ses
         ses_str = num2str(i_ses,'%02i');
         list = spm_select('ExtFPList', fullfile(base_dir, 'Nifti', ['sub-' sub_str], ['ses-' ses_str], 'func'),['^warsub.*' filter]);
         if ~isempty(list)
            files{end+1} = cellstr(list);
         end
    end
elseif n_ses == 1
    % Check if output images already exist
    check_file = dir(fullfile(base_dir, 'Nifti', ['sub-' sub_str], 'func', ['swarsub*' filter '*']));
    list = spm_select('ExtFPList', fullfile(base_dir, 'Nifti', ['sub-' sub_str], 'func'),['^warsub.*' filter]);
    files{end+1} = cellstr(list);
end

% Check if input files are present
if isempty(files)
    warning('Subject %d - smoothing: no input files found.', sub_id);
    return;
end

% Overwrite if requested
if ~isempty(check_file) && p.OVERWRITE == 1
    warning('FILES WILL BE OVERWRITTEN!!! If this was a mistake, abort now!');
    pause(5);
    
    for i_ses = 1:n_ses
        ses_str = num2str(i_ses,'%02i');
        delete(fullfile(base_dir, 'Nifti', ['sub-' sub_str], ['ses-' ses_str], 'func', ['swarsub*' filter '*']));
    end
    check_file = [];
end

% Run
if isempty(check_file)

    model{1}.spm.spatial.smooth.data = reshape([files{:}],[],1);                   % realigned, slice time corrected, normalised images

    % smoothing opthions
    model{1}.spm.spatial.smooth.fwhm = fwhm;                             % Gaussian smoothing kernel in mm
    model{1}.spm.spatial.smooth.dtype = 0;                               % output data type (0: same)
    model{1}.spm.spatial.smooth.im = 0;                                  % implicit maskin (0: no)
    model{1}.spm.spatial.smooth.prefix = 's';                            % filename prefix
   
    fprintf('\nSubject %d - perform smoothing of functional images.', sub_id)

    spm('defaults', 'FMRI'); 
    spm_jobman('run', model);
else
    warning('Subject %d - smoothed functional images already exist, skip smoothing.', sub_id)
end