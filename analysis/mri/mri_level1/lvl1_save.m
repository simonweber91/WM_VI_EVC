function lvl1_save(i_sub, p, model)


base_dir                = p.base_dir;
title                   = p.lvl1.title;

sub_str                 = num2str(i_sub,'%02i');

out_file = fullfile(base_dir, 'Nifti', ['sub-' sub_str], 'lvl1', title, ['lvl1_log_' datestr(now,'yymmddHHMM') '.mat']);

% only save if there are non-empty cells
if ~all(cellfun(@isempty, model))
    
    % detect empty cells
    e = cellfun(@isempty, model);
    model(e) = [];

    save(out_file, 'model', 'p')
else
    warning('Subject %d - Model structure completely empty, no log saved.', i_sub)
end