function pSVR_save(sub_id, p, predictions, results, suffix)

% function mtSVR_save(sub_id, p, predictions, results, suffix)
%
% Save final result file during ongoing analysis. Variables include:
%   - sub_id: ID of the current subject.
%   - p: Structure with analysis
%       parameters. 
%   - predictions: Structure containing the angular/sine/cosine
%       predictions and true labels of all analysis runs.
%   - results: Structure with reconstruction results.
%   - suffix: Suffix to append to the filename.
%
% Simon Weber, sweber@bccn-berlin.de, 2021

% Get filename
filename = get_filename(sub_id, p);

% Append timestamp
out_file = [filename '_' suffix '_' datestr(now,'yymmddHHMM') '.mat'];

% Save
save(out_file, 'p', 'predictions', 'results', '-v7.3');

% Delete temp file if necessary
if exist([filename '_' suffix '_temp.mat'],'file')
    delete([filename '_' suffix '_temp.mat']);
end

fprintf('Results saved as %s\n', out_file);
    