function dicom2nifti_bids(p)

% function dicom2nifti_bids(p)
%
% Converts Dicom to Nifti images and stores them in a BIDS folder
% structure. Inside the function, specify a number of 'filter' strings that
% can be used to identify the appropriate files.
%
% Input:
%   - p: Structure with analysis parameters, including base directory of
%       the project and subject IDs.
%
% Simon Weber, sweber@bccn-berlin.de, 2021

base_dir                = p.base_dir;                                       % base directory of study

subjects                = p.subjects;                                       % subjects to process
n_sessions              = p.n_session;                                      % number of sessions

anat_filter             = 'T1w_MPR';                                        % to filter T1 image
func_filter             = 'fMRI_AP';                                        % to filter functional images
ret_filter              = 'Retinotopy';                                     % to filter retinotopy
fmap_filter             = 'SpinEchoFieldMap_AP';                            % to filter AP fieldmap
fmpa_filter             = 'SpinEchoFieldMap_PA';                            % to filter PA fieldmap
    
task                    = 'vwm';                                            % name of task, according to BIDS convention
    

for i_sub = 1:numel(subjects)

    % Get subject ID
    sub_id = p.subjects(i_sub);
    
    sub_str = num2str(sub_id,'%02i');
    
    for i_ses = 1:n_sessions
        
        ses_str = num2str(i_ses,'%02i');
        
        dcm_dir = fullfile(base_dir, 'Dicom', ['sub-' sub_str], ['ses-' ses_str]);
        
        %%% Convert anatomical image %%%
        anat_in = cellstr(spm_select('FPList',dcm_dir,'dir',anat_filter));
        if numel(anat_in) > 2 
            warning(['Subject ' sub_str ' - more than 1 T1 image, skip.']);
        else
            anat_in = anat_in{end};
            anat_out = fullfile(base_dir, 'Nifti', ['sub-' sub_str], ['ses-' ses_str],'anat');
            anat_fname = sprintf('sub-%02d_ses-%02d_T1w', sub_id, i_ses);

            if ~exist(fullfile(anat_out, [anat_fname '.nii']),'file')

                command = sprintf('dcm2niix %s', anat_in);
                [~,cmdout] = system(command);
                disp(cmdout);

                nii = dir(fullfile(anat_in,'*.nii'));
                json = dir(fullfile(anat_in,'*.json'));
                movefile(fullfile(anat_in, nii(1).name), fullfile(anat_out, [anat_fname '.nii']));
                movefile(fullfile(anat_in,json(1).name), fullfile(anat_out, [anat_fname '.json']));
                fprintf(['\n' fullfile(anat_in, nii(1).name) ' moved to ' fullfile(anat_out, [anat_fname '.nii'])]);
                fprintf(['\n' fullfile(anat_in, json(1).name) ' moved to ' fullfile(anat_out, [anat_fname '.json'])]);
            else 
                warning(['Subject ' sub_str ' - Anatomical image ' fullfile(anat_out, [anat_fname '.nii']) ' already exists.']);
            end
        end
        
        %%% Convert fuctional images and fieldmaps %%%
        func_dirs = cellstr(spm_select('FPList',dcm_dir,'dir',func_filter));
        func_dirs(1:2:numel(func_dirs)) = [];                                 % select valid folders
        
        if numel(func_dirs) > 4
            warning(['Subject ' sub_str ' - More than 4 functional images, please check.']);
        elseif numel(func_dirs) < 4
            warning(['Subject ' sub_str ' - Less than 4 functional images, please check.']);
        end
        
        func_out = fullfile(base_dir, 'Nifti', ['sub-' sub_str], ['ses-' ses_str],'func');
        
        fmap_dirs = cellstr(spm_select('FPList',dcm_dir,'dir',fmap_filter));
        fmpa_dirs = cellstr(spm_select('FPList',dcm_dir,'dir',fmpa_filter));
        fm_out = fullfile(base_dir, 'Nifti', ['sub-' sub_str], ['ses-' ses_str],'fmap');
        
        for i_func = 1:numel(func_dirs)
            
            %%% Convert task runs %%%
            func_in = func_dirs{i_func};
            func_fname = sprintf('sub-%02d_ses-%02d_task-%s_run-%02d_bold', sub_id, i_ses, task, i_func);
            
            if ~exist(fullfile(func_out, [func_fname '.nii']),'file')

                command = sprintf('dcm2niix %s', func_in);
                [~,cmdout] = system(command);
                disp(cmdout);

                nii = dir(fullfile(func_in,'*.nii'));
                json = dir(fullfile(func_in,'*.json'));
                movefile(fullfile(func_in, nii(1).name), fullfile(func_out, [func_fname '.nii']));
                movefile(fullfile(func_in,json(1).name), fullfile(func_out, [func_fname '.json']));
                fprintf(['\n' fullfile(func_in, nii(1).name) ' moved to ' fullfile(func_out, [func_fname '.nii'])]);
                fprintf(['\n' fullfile(func_in, json(1).name) ' moved to ' fullfile(func_out, [func_fname '.json'])]);
            else 
                warning(['Subject ' sub_str ' - Functional image ' fullfile(func_out, [func_fname '.nii']) ' already exists.']);
            end
            
            % Convert AP fieldmap %%%
            fmap_in = fmap_dirs{i_func};
            fmap_fname = sprintf('sub-%02d_ses-%02d_run-%02d_ap', sub_id, i_ses, i_func);
            
            if ~exist(fullfile(fm_out, [fmap_fname '.nii']),'file')

                command = sprintf('dcm2niix %s', fmap_in);
                [~,cmdout] = system(command);
                disp(cmdout);

                nii = dir(fullfile(fmap_in,'*.nii'));
                json = dir(fullfile(fmap_in,'*.json'));
                movefile(fullfile(fmap_in, nii(1).name), fullfile(fm_out, [fmap_fname '.nii']));
                movefile(fullfile(fmap_in,json(1).name), fullfile(fm_out, [fmap_fname '.json']));
                fprintf(['\n' fullfile(fmap_in, nii(1).name) ' moved to ' fullfile(fm_out, [fmap_fname '.nii'])]);
                fprintf(['\n' fullfile(fmap_in, json(1).name) ' moved to ' fullfile(fm_out, [fmap_fname '.json'])]);
            else 
                warning(['Subject ' sub_str ' - FieldMap image ' fullfile(fm_out, [fmap_fname '.nii']) ' already exists.']);
            end
            
            % Conver PA fieldmap %%%
            fmpa_in = fmpa_dirs{i_func};
            fmpa_fname = sprintf('sub-%02d_ses-%02d_run-%02d_pa', sub_id, i_ses, i_func);
            
            if ~exist(fullfile(fm_out, [fmpa_fname '.nii']),'file')

                command = sprintf('dcm2niix %s', fmpa_in);
                [~,cmdout] = system(command);
                disp(cmdout);

                nii = dir(fullfile(fmpa_in,'*.nii'));
                json = dir(fullfile(fmpa_in,'*.json'));
                movefile(fullfile(fmpa_in, nii(1).name), fullfile(fm_out, [fmpa_fname '.nii']));
                movefile(fullfile(fmpa_in,json(1).name), fullfile(fm_out, [fmpa_fname '.json']));
                fprintf(['\n' fullfile(fmpa_in, nii(1).name) ' moved to ' fullfile(fm_out, [fmpa_fname '.nii'])]);
                fprintf(['\n' fullfile(fmpa_in, json(1).name) ' moved to ' fullfile(fm_out, [fmpa_fname '.json'])]);
            else 
                warning(['Subject ' sub_str ' - FieldMap image ' fullfile(fm_out, [fmpa_fname '.nii']) ' already exists.']);
            end
            
        end
        
        %%% Convert retinotopy %%%
        try ret_in = cellstr(spm_select('FPList',dcm_dir,'dir',ret_filter)); end
        if ~isempty(ret_in{1})
        if numel(ret_in) > 2
            warning(['Subject ' sub_str ' - more than 1 retinotopy image, skip.']);
        else
            ret_in = ret_in{end};
            if ~isempty(ret_in)
                
                % Convert retinotopy %%%
                ret_fname = sprintf('sub-%02d_ses-%02d_task-retinotopy_bold', sub_id, i_ses);

                if ~exist(fullfile(func_out, [ret_fname '.nii']),'file')

                    command = sprintf('dcm2niix %s', ret_in);
                    [~,cmdout] = system(command);
                    disp(cmdout);

                    nii = dir(fullfile(ret_in,'*.nii'));
                    json = dir(fullfile(ret_in,'*.json'));
                    movefile(fullfile(ret_in, nii(1).name), fullfile(func_out, [ret_fname '.nii']));
                    movefile(fullfile(ret_in,json(1).name), fullfile(func_out, [ret_fname '.json']));
                    fprintf(['\n' fullfile(ret_in, nii(1).name) ' moved to ' fullfile(func_out, [ret_fname '.nii'])]);
                    fprintf(['\n' fullfile(ret_in, json(1).name) ' moved to ' fullfile(func_out, [ret_fname '.json'])]);
                else 
                    warning(['Subject ' sub_str ' - Retinotopy image ' fullfile(func_out, [func_fname '.nii']) ' already exists.']);
                end 
                
                % Convert AP fieldmap %%%
                fmap_in = fmap_dirs{end};
                fmap_fname = sprintf('sub-%02d_ses-%02d_retinotopy-ap', sub_id, i_ses);

                if ~exist(fullfile(fm_out, [fmap_fname '.nii']),'file')

                    command = sprintf('dcm2niix %s', fmap_in);
                    [~,cmdout] = system(command);
                    disp(cmdout);

                    nii = dir(fullfile(fmap_in,'*.nii'));
                    json = dir(fullfile(fmap_in,'*.json'));
                    movefile(fullfile(fmap_in, nii(1).name), fullfile(fm_out, [fmap_fname '.nii']));
                    movefile(fullfile(fmap_in,json(1).name), fullfile(fm_out, [fmap_fname '.json']));
                    fprintf(['\n' fullfile(fmap_in, nii(1).name) ' moved to ' fullfile(fm_out, [fmap_fname '.nii'])]);
                    fprintf(['\n' fullfile(fmap_in, json(1).name) ' moved to ' fullfile(fm_out, [fmap_fname '.json'])]);
                else 
                    warning(['Subject ' sub_str ' - FieldMap image ' fullfile(fm_out, [fmap_fname '.nii']) ' already exists.']);
                end
            
                %%%% Convert PA fieldmap %%%
                fmpa_in = fmpa_dirs{end};
                fmpa_fname = sprintf('sub-%02d_ses-%02d_retinotopy-pa', sub_id, i_ses);

                if ~exist(fullfile(fm_out, [fmpa_fname '.nii']),'file')

                    command = sprintf('dcm2niix %s', fmpa_in);
                    [~,cmdout] = system(command);
                    disp(cmdout);

                    nii = dir(fullfile(fmpa_in,'*.nii'));
                    json = dir(fullfile(fmpa_in,'*.json'));
                    movefile(fullfile(fmpa_in, nii(1).name), fullfile(fm_out, [fmpa_fname '.nii']));
                    movefile(fullfile(fmpa_in,json(1).name), fullfile(fm_out, [fmpa_fname '.json']));
                    fprintf(['\n' fullfile(fmpa_in, nii(1).name) ' moved to ' fullfile(fm_out, [fmpa_fname '.nii'])]);
                    fprintf(['\n' fullfile(fmpa_in, json(1).name) ' moved to ' fullfile(fm_out, [fmpa_fname '.json'])]);
                else 
                    warning(['Subject ' sub_str ' - FieldMap image ' fullfile(fm_out, [fmpa_fname '.nii']) ' already exists.']);
                end
            
            end
        end
        end
    end
end





