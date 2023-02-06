function model = pp_realign(sub_id, p)

% function model = pp_realign(sub_id, p)
%
% Runs SPM realignment (i.e. head motion correction) on unprocessed fMRI
% images.
%
% Input:
%   - sub_id: ID of the current subject.
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
n_run                   = p.n_run;
filter                  = p.img.filter;

% Get subject ID as string
sub_str                 = num2str(sub_id,'%02i');

% initialize output variable
model = {};

% Get input images for all sessions and runs
files = {};
if n_ses > 1
    % Check if output images already exist
    check_file = dir(fullfile(base_dir, 'Nifti', ['sub-' sub_str], 'ses-01', 'func', ['meansub*' filter '*']));
    for i_ses = 1:n_ses
         ses_str = num2str(i_ses,'%02i');
         for i_run = 1:n_run
             run_str = num2str(i_run,'%02i');
             list = spm_select('ExtFPList', fullfile(base_dir, 'Nifti', ['sub-' sub_str], ['ses-' ses_str], 'func'), ['^sub.*' filter '.*run-' run_str]);
             if ~isempty(list)
                files{end+1} = cellstr(list);
             end
         end
    end
elseif n_ses == 1
    % Check if output images already exist
    check_file = dir(fullfile(base_dir, 'Nifti', ['sub-' sub_str], 'func', ['meansub*' filter '*']));
    for i_run = 1:n_run
        run_str = num2str(i_run,'%02i');
        list = spm_select('ExtFPList', fullfile(base_dir, 'Nifti', ['sub-' sub_str], 'func'), ['^sub.*' filter '.*run-' run_str]);
        files{end+1} = cellstr(list);
    end
end

% Check if input files are present
if isempty(files)
    warning('Subject %d - realignment: no input files found.', sub_id);
    return;
end

% Overwrite if requested
if ~isempty(check_file) && p.OVERWRITE == 1
    warning('FILES WILL BE OVERWRITTEN!!! If this was a mistake, abort now!');
    pause(5);

    delete(fullfile(check_file(1).folder, check_file.name));
    for i_ses = 1:n_ses
        ses_str = num2str(i_ses,'%02i');
        delete(fullfile(base_dir, 'Nifti', ['sub-' sub_str], ['ses-' ses_str], 'func', ['rsub*' filter '*']));
        delete(fullfile(base_dir, 'Nifti', ['sub-' sub_str], ['ses-' ses_str], 'func', ['rp_sub*' filter '*']));
    end
    check_file = [];
end

% Run
if isempty(check_file)

    model{1}.spm.spatial.realign.estwrite.data                = files';

    % Realignment options
    model{1}.spm.spatial.realign.estwrite.eoptions.quality    = 0.9;
    model{1}.spm.spatial.realign.estwrite.eoptions.sep        = 4;
    model{1}.spm.spatial.realign.estwrite.eoptions.fwhm       = 5;
    model{1}.spm.spatial.realign.estwrite.eoptions.rtm        = 0;
    model{1}.spm.spatial.realign.estwrite.eoptions.interp     = 2;
    model{1}.spm.spatial.realign.estwrite.eoptions.wrap       = [0 0 0];

    model{1}.spm.spatial.realign.estwrite.eoptions.weight     = '';
    model{1}.spm.spatial.realign.estwrite.roptions.which      = [2 1];
    model{1}.spm.spatial.realign.estwrite.roptions.interp     = 4;
    model{1}.spm.spatial.realign.estwrite.roptions.wrap       = [0 0 0];
    model{1}.spm.spatial.realign.estwrite.roptions.mask       = 1;
    model{1}.spm.spatial.realign.estwrite.roptions.prefix     = 'r';
    
    fprintf('\nSubject %d - perform realignment.', sub_id)

    spm('defaults', 'FMRI'); 
    spm_jobman('run', model);
       
else
    warning('Subject %d - mean functional image already exists, skip realignment.', sub_id)
end
