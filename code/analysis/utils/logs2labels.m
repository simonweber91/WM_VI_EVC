function logs2labels(p)

for i_sub = 1:numel(p.subjects)
    % Get subject ID
    sub_id = p.subjects(i_sub);
    % Get subject ID as string
    sub_str = num2str(i_sub,'%02i');

    try
    % Get name of output file
    label_dir = fullfile(p.dirs.data, 'analysis', ['sub-' sub_str], 'labels');
    if exist(fullfile(label_dir, 'task_labels.mat'), 'file')
        load(fullfile(label_dir, 'task_labels.mat'), 'task_labels');
    else
        if ~exist(label_dir, 'dir'), mkdir(label_dir); end
        task_labels = struct();
    end

    % Load experimental logfiles
    [log, ~ ,experiment] = load_log(sub_id, p);
    
    % Get labels
    for l = 1:numel(p.psvr.all_labels)
        if ~isfield(task_labels, p.psvr.all_labels{l})
            task_labels.(p.psvr.all_labels{l}) = extract_labels(log, experiment, p.psvr.all_labels{l});
        end
    end
    
    % Get misses
    if ~isfield(task_labels, 'misses')
        task_labels.misses = extract_labels(log, experiment, 'misses');
    end
    
    % Save labels
    save(fullfile(label_dir, 'task_labels.mat'), 'task_labels')
    catch
        warning(['No logfiles found for subject ' sub_str '.'])
    end
end
