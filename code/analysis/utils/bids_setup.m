function bids_setup(p)

% function bids_setup(p)
%
% Creates a folder structure according to the BIDS organizational standard.
% More information at:
% http://reproducibility.stanford.edu/bids-tutorial-series-part-1a/#man2
%
% Input:
%   - p: Structure with analysis parameters, including base directory of
%       the project and subject IDs.
%
% Simon Weber, sweber@bccn-berlin.de, 2021


nifti_dir                = fullfile(p.dirs.data, 'Nifti');                   % where to set up

def_folders             = {'anat', 'func', 'fmap'};                         % standard BIDS folder
add_folders             = {''};                                             % additional folders

for i_sub = 1:numel(p.subjects)

    % Get subject ID
    sub_id = p.subjects(i_sub);
    
    sub_str = num2str(sub_id,'%02i');
    
    % make subject directory
    sub_dir = fullfile(nifti_dir, ['sub-' sub_str]);
    if ~exist(sub_dir,'dir'), mkdir(sub_dir); end
    
    if p.n_session == 1
        % make default BIDS folders
        for i_def = 1:numel(def_folders)
            folder = fullfile(sub_dir, def_folders{i_def});
            if ~exist(folder,'dir'), mkdir(folder); end
        end
        
        % make additional folders
        for i_add = 1:numel(add_folders)
            folder = fullfile(sub_dir, add_folders{i_add});
            if ~exist(folder,'dir'), mkdir(folder); end
        end
    
    elseif p.n_session > 1
        % for every session...
        for i_ses = 1:p.n_session

            ses_str = num2str(i_ses,'%02i');

            % make session directory
            ses_dir = fullfile(sub_dir, ['ses-' ses_str]);
            if ~exist(ses_dir,'dir'), mkdir(ses_dir); end

            % make default BIDS folders
            for i_def = 1:numel(def_folders)
                folder = fullfile(ses_dir, def_folders{i_def});
                if ~exist(folder,'dir'), mkdir(folder); end
            end

            % make additional folders
            for i_add = 1:numel(add_folders)
                folder = fullfile(ses_dir, add_folders{i_add});
                if ~exist(folder,'dir'), mkdir(folder); end
            end
        end
    end
end










