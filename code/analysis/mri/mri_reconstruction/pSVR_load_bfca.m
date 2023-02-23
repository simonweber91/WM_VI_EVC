function bfca = pSVR_load_bfca(p)


bfca_temp = zeros(numel(p.subjects), p.psvr.n_tr, p.psvr.n_perm + 1);

for i_sub = 1:numel(p.subjects)

    % Get subject ID
    sub_id = p.subjects(i_sub);
    % Get subject ID as string
    sub_str = num2str(sub_id,'%02i');

    % Load reconstruction results
    bfca_file = dir(fullfile(p.dirs.data, 'analysis', ['sub-' sub_str], 'results', ['bfca_' p.psvr.label '_' p.psvr.roi '.mat']));
    if isempty(bfca_file)
        warning('Subject %d - missing results file, cannot load results for all subejcts.', sub_id)
        bfca = [];
        return;
    end

    load(fullfile(bfca_file.folder, bfca_file.name), 'bfca');

    bfca_temp(i_sub,:,:) = permute(bfca,[3 2 1]);
end

bfca = bfca_temp;