function lvl2_save(p, model)


data_dir                = p.dirs.data;
title                   = p.lvl1.title;

out_file = fullfile(data_dir, 'Nifti', 'all', 'lvl2', title, ['lvl2_log_' datestr(now,'yymmddHHMM') '.mat']);

% only save if there are non-empty cells
if ~all(cellfun(@isempty, model))
    
    % detect empty cells
    e = cellfun(@isempty, model);
    model(e) = [];

    save(out_file, 'model', 'p')
else
    warning('Model structure completely empty, no log saved.')
end