function pp_partition_rp_files(sub_id, p)

% function pp_partition_rp_files(sub_id, p)
%
% Takes the rp*.txt files containing the realignment-parameters estimated
% with pp_realign.m for each experimental session, and saves them for each
% individual run. This is necessary to include them as regressors of no
% interest in the 1st-level analysis.
%
% Input:
%   - i_sub: ID of the current subject.
%   - p: Structure with analysis parameters.
%
% Simon Weber, sweber@bccn-berlin.de, 2020

% Exptract relevant variables from p
base_dir                = p.base_dir;
n_ses                   = p.n_session;
n_run                   = p.n_run;
filter                  = p.img.filter;

% Get subject ID as string
sub_str                 = num2str(sub_id,'%02i');

if n_ses > 1
    for i_ses = 1:n_ses

        % Get session ID as string
        ses_str = num2str(i_ses,'%02i');

        % Check if rp-files have already bee partitioned
        if isempty(dir(fullfile(base_dir, 'Nifti', ['sub-' sub_str], ['ses-' ses_str], 'func', ['rp_sub*' filter '_all-runs*'])))

            % Get rp-file of current session and rename it
            rp_file = dir(fullfile(base_dir, 'Nifti', ['sub-' sub_str], ['ses-' ses_str], 'func', ['rp_sub*' filter '*']));
            all_name = strrep(rp_file.name,'run-01','all-runs');
            movefile(fullfile(rp_file.folder, rp_file.name), fullfile(rp_file.folder, all_name));

            % Load the text data contained in the rp-file
            data = importdata(fullfile(rp_file.folder, all_name));
            fpr = size(data,1)/n_run;

            % For each run...
            for i_run = 1:n_run

                % Get runID as string
                run_str = num2str(i_run,'%02i');

                % Create a new file for this run
                new_name = strrep(rp_file.name,'run-01',['run-' run_str]);
                new_file = fopen(fullfile(rp_file.folder, new_name),'w');

                % Extract the relevant data from the original file and
                % write it into the run-specific file
                ind = [(fpr*(i_run-1))+1:fpr*i_run];
                fprintf(new_file, '%.10f\t%.10f\t%.10f\t%.10f\t%.10f\t%.10f \n', data(ind,:)');
                fclose(new_file);
            end
        end
    end
    
elseif n_ses == 1

    % Check if rp-files have already bee partitioned
    if isempty(dir(fullfile(base_dir, 'Nifti', ['sub-' sub_str], 'func', ['rp_sub*' filter '_all-runs*'])))

        % Get rp-file of current session and rename it
        rp_file = dir(fullfile(base_dir, 'Nifti', ['sub-' sub_str], 'func', ['rp_sub*' filter '*']));
        all_name = strrep(rp_file.name,'run-01','all-runs');
        movefile(fullfile(rp_file.folder, rp_file.name), fullfile(rp_file.folder, all_name));

        % Load the text data contained in the rp-file
        data = importdata(fullfile(rp_file.folder, all_name));
        fpr = size(data,1)/n_run;

        % For each run...
        for i_run = 1:n_run

            % Get runID as string
            run_str = num2str(i_run,'%02i');

            % Create a new file for this run
            new_name = strrep(rp_file.name,'run-01',['run-' run_str]);
            new_file = fopen(fullfile(rp_file.folder, new_name),'w');

            % Extract the relevant data from the original file and
            % write it into the run-specific file
            ind = [(fpr*(i_run-1))+1:fpr*i_run];
            fprintf(new_file, '%.10f\t%.10f\t%.10f\t%.10f\t%.10f\t%.10f \n', data(ind,:)');
            fclose(new_file);
        end
    end
end