function filename = get_filename(sub_id, p)

% function filename = get_filename(sub_id, p)
%
% Create filename for final result file.
%
% Input:
%   - sub_id: ID of the current subject.
%   - p: Structure with analysis parameters.
%
% Output:
%   - filename: Filename (including file path, excluding timestamp) of
%       final result file.
%
% Simon Weber, sweber@bccn-berlin.de, 2021

% Get subject ID as string
sub_str = num2str(sub_id,'%02i');

% Get directory for final result file
file_dir = fullfile(p.base_dir, 'Nifti', ['sub-' sub_str], 'predictions', 'pSVR');
if ~exist(file_dir,'dir'), mkdir(file_dir); end

%%% Create filename %%%
name = [p.psvr.event '_' p.psvr.label '_' p.psvr.roi];

% Combine directory and filename
filename = fullfile(file_dir, name);


    

