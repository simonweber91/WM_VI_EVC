function model = lvl2_2samplettest_specify(p)

% Exptract relevant variables from p
data_dir                = p.dirs.data;
title                   = p.lvl1.title;

% Initialize output variable
model = {};

files = {};
for i_sub = 1:numel(p.subjects)
    sub_str = num2str(p.subjects(i_sub),'%02i');
    list = spm_select('ExtFPList', fullfile(data_dir, 'Nifti', ['sub-' sub_str], 'lvl1', title), ['^con_0001']);
    if ~isempty(list)
        files{i_sub, 1} = cellstr(list);
    end
end

if isempty(files)
    warning('No input data found, can''t perform 2nd level specification.');
    return;
elseif numel(files) ~= numel(p.subjects)
    warning('Input data missing for one or more subjects, can''t perform 2nd level specification.');
    return;
end

% Check if output directory exists, create if not
out_dir = fullfile(data_dir, 'Nifti', 'all', 'lvl2', title);
if ~exist(out_dir,'dir'), mkdir(out_dir); end

%%%% CAUTION: OVERWRITES SPM FILE!!! %%%%
if exist(fullfile(out_dir,'SPM.mat'),'file') && p.OVERWRITE == 1
    warning('FILES WILL BE OVERWRITTEN!!! If this was a mistake, abort now!');
    pause(5);
    
    delete(fullfile(out_dir,'*'));
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% Model Specification %%%
if ~exist(fullfile(out_dir,'SPM.mat'),'file')

    % Load VVIQ scores
    [~, high, low] = vviq_scores(p);

    model{1}.spm.stats.factorial_design.dir = {out_dir};

    model{1}.spm.stats.factorial_design.des.t2.scans1 = files(high);
    model{1}.spm.stats.factorial_design.des.t2.scans2 = files(low);

    model{1}.spm.stats.factorial_design.des.t2.dept = 0;
    model{1}.spm.stats.factorial_design.des.t2.variance = 1;
    model{1}.spm.stats.factorial_design.des.t2.gmsca = 0;
    model{1}.spm.stats.factorial_design.des.t2.ancova = 0;
    model{1}.spm.stats.factorial_design.cov = struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {});
    model{1}.spm.stats.factorial_design.multi_cov = struct('files', {}, 'iCFI', {}, 'iCC', {});
    model{1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
    model{1}.spm.stats.factorial_design.masking.im = 1;
    model{1}.spm.stats.factorial_design.masking.em = {''};
    model{1}.spm.stats.factorial_design.globalc.g_omit = 1;
    model{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
    model{1}.spm.stats.factorial_design.globalm.glonorm = 1;

    fprintf('\n2nd level specification - two-sample t-test.')
    
    %%% Run %%%
    spm('defaults', 'FMRI'); 
    spm_jobman('run', model);

end