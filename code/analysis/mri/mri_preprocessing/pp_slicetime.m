function model = pp_slicetime(sub_id, p)

% function model = pp_slicetime(sub_id, p)
%
% Runs SPM slice time correction on realigned fMRI images.
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
data_dir                = p.dirs.data;
n_ses                   = p.n_session;
filter                  = p.img.filter;
n_slice                 = p.img.n_slice;
tr                      = p.img.tr;
p.img.slice_order       = [1 10 19 28 37 46 55 64 3 12 21 30 39 48 57 66 5 14 23 32 41 50 59 68 7 16 25 34 43 52 61 70 9 18 27 36 45 54 63 72 2 11 20 29 38 47 56 65 4 13 22 31 40 49 58 67 6 15 24 33 42 51 60 69 8 17 26 35 44 53 62 71];
slice_order             = p.img.slice_order;

% Get subject ID as string
sub_str                 = num2str(sub_id,'%02i');

% initialize output variable
model = {};

% Get (realigned) input images for all sessions and runs
files = {};
if n_ses > 1
    % Check if output images already exist
    check_file = dir(fullfile(data_dir, 'Nifti', ['sub-' sub_str], 'ses-01', 'func', ['arsub*' filter '*']));
    for i_ses = 1:n_ses
         ses_str = num2str(i_ses,'%02i');
         list = spm_select('ExtFPList', fullfile(data_dir, 'Nifti', ['sub-' sub_str], ['ses-' ses_str], 'func'),['^rsub.*' filter]);
         if ~isempty(list)
            files{end+1} = cellstr(list);
         end
    end
elseif n_ses == 1
    % Check if output images already exist
    check_file = dir(fullfile(data_dir, 'Nifti', ['sub-' sub_str], 'func', ['arsub*' filter '*']));
    list = spm_select('ExtFPList', fullfile(data_dir, 'Nifti', ['sub-' sub_str], 'func'),['^rsub.*' filter]);
    files{end+1} = cellstr(list);
end

% Check if input files are present
if isempty(files)
    warning('Subject %d - slicetime: no input files found.', sub_id);
    return;
end

% Overwrite if requested
if ~isempty(check_file) && p.OVERWRITE == 1
    warning('FILES WILL BE OVERWRITTEN!!! If this was a mistake, abort now!');
    pause(5);
    
    for i_ses = 1:n_ses
        ses_str = num2str(i_ses,'%02i');
        delete(fullfile(data_dir, 'Nifti', ['sub-' sub_str], ['ses-' ses_str], 'func', ['arsub*' filter '*']));
    end
    check_file = [];
end

% Run
if isempty(check_file)

    model{1}.spm.temporal.st.scans        = files';                     % realigned images

    % Slice timing options
    model{1}.spm.temporal.st.nslices      = n_slice;                     % number of slices (N)
    model{1}.spm.temporal.st.tr           = tr;                                    % TR
    model{1}.spm.temporal.st.ta           = tr-tr/n_slice;                    % TA (TR-TR/N)
    model{1}.spm.temporal.st.so           = slice_order;                       % slice order (ascending interleaved2)
    model{1}.spm.temporal.st.refslice     = round(n_slice/2);           % reference slice (N/2)
    model{1}.spm.temporal.st.prefix       = 'a';                               % filename prefix

    fprintf('\nSubject %d - slice time correction.', sub_id)
    
    spm('defaults', 'FMRI'); 
    spm_jobman('run', model);
    
else
    warning('Subject %d - slice time corrected images already exist, skip slice time correction.', sub_id)
end

