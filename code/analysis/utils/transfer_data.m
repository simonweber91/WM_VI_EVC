function transfer_data(p)

if isempty(p.dirs.source), return; end

%%% Transfer DICOM files %%%
fprintf('Trasferring DICOM ... \n')
for i_sub = 1:numel(p.subjects)
    % Get subject ID
    sub_id = p.subjects(i_sub);
    % Get subject ID as string
    sub_str = num2str(sub_id,'%02i');
    for i_ses = 1:p.n_session
        % Get session ID as string
        ses_str = num2str(i_ses,'%02i');
        % Get files
        source = fullfile(p.dirs.source, 'Dicom', ['sub-' sub_str], ['ses-' ses_str]);
        files = dir(fullfile(source, ['*.zip']));
        % Where to transfer to
        destination = fullfile(p.dirs.data, 'Dicom', ['sub-' sub_str], ['ses-' ses_str]);
        if ~exist(destination, 'dir'), mkdir(destination); end
        % Ttransfer files
        if ~isempty(files)
            if exist(fullfile(files.folder, files.name), 'file') && ~exist(fullfile(destination, files.name), 'file')
                copyfile(fullfile(files.folder, files.name), destination);
                unzip(fullfile(destination, files.name), destination);
            end
        end
    end
end


%%% Transfer log files %%%
fprintf('Trasferring logfiles ... \n')
for i_sub = 1:numel(p.subjects)
    % Get subject ID
    sub_id = p.subjects(i_sub);
    % Get subject ID as string
    sub_str = num2str(sub_id,'%02i');
    for i_ses = 1:p.n_session
        % Get session ID as string
        ses_str = num2str(i_ses,'%02i');
        % Get files
        source = fullfile(p.dirs.source, 'logs', ['sub-' sub_str], ['ses-' ses_str]);
        files = dir(fullfile(source, ['*' p.img.filter '*']));
        % Where to transfer to
        destination = fullfile(p.dirs.data, 'logs', ['sub-' sub_str], ['ses-' ses_str]);
        if ~exist(destination, 'dir'), mkdir(destination); end
        % Ttransfer files
        if ~isempty(files)
            for i_f = 1:numel(files)
                if exist(fullfile(files(i_f).folder, files(i_f).name), 'file') && ~exist(fullfile(destination, files(i_f).name), 'file')
                    copyfile(fullfile(files(i_f).folder, files(i_f).name), destination);
                end
            end
        end
    end
end

%%% Transfer VVIQ data %%%
fprintf('Trasferring VVIQ data ... \n')
source = fullfile(p.dirs.source, 'vviq');
files = dir(fullfile(source, 'VVIQ.mat'));
destination = fullfile(p.dirs.data, 'vviq');
if ~exist(destination, 'dir'), mkdir(destination); end
if ~isempty(files)
    if exist(fullfile(files.folder, files.name), 'file') && ~exist(fullfile(destination, files.name), 'file')
        copyfile(fullfile(files.folder, files.name), destination);
    end
end

%%% Transfer ROI data %%%
fprintf('Trasferring ROI data ... \n')
source = fullfile(p.dirs.source, 'Nifti', 'all', 'rois');
files = dir(source);
destination = fullfile(p.dirs.data, 'Nifti', 'all', 'rois');
if ~exist(destination, 'dir'), mkdir(destination); end
if ~isempty(files)
    for i_f = 3:numel(files)
        if exist(fullfile(files(i_f).folder, files(i_f).name)) && ~exist(fullfile(destination, files(i_f).name))
            copyfile(fullfile(files(i_f).folder, files(i_f).name), fullfile(destination, files(i_f).name));
        end
    end
end