function [vviq_score, high, low] = vviq_scores(p)

% function [vviq_score, high, low] = vviq_scores(p)
%
% Load data of the Vividness of Visual Imagery Questionnaire (Marks, 1975)
% used for recruitment. Extract the VVIQ scores of the selected
% participants.
%
% Output:
%   - vviq_score: Vector of VVIQ scores
%   - high: Logical array. 1 if the subject with the corresponding ID
%       belongs to the high imagery group, 0 otherwise.
%   - low: Logical array. 1 if the subject with the corresponding ID
%       belongs to the low imagery group, 0 otherwise.
%
% Simon Weber, sweber@bccn-berlin.de, 2021

% % Load questionnaire data
% load('/analysis/sweber/projects/visimg/Questionnaire/recruitment/VVIQ.mat');
% vviq = VVIQ.vviq;

vviq_score = [];
high = []; low = [];

vviq_file = dir(fullfile(p.dirs.data, 'analysis', 'all', 'results', 'vviq.mat'));
if isempty(vviq_file)
    warning('vviq.mat not found.');
    return;
end

load(fullfile(vviq_file.folder, vviq_file.name), 'vviq')

% IDs of MRI participants
online_ID = {'H037','H047','L034','H088','L119','L095','L033','L206','H065','H178','H190','H088','H233','H330','L299','H237','L395','H349','H337','H365','L325','H362','L236','H250','H453','L248','H268','L280','L391','L487','H545','H547','H523','L499','H554','L536','L520','L662','L599','L691'};
vviq_ID = [37,47,34,88,119,95,33,206,65,178,190,86,233,330,299,237,395,349,337,365,325,362,236,250,453,248,268,280,391,487,545,547,523,499,554,536,520,662,599,691];
mri_ID = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42];

% Subjects with missing MRI data
invited_but_missing_data_online_ID = {'H064', 'H517'};
invited_but_missing_data_ID = [64, 517];

% Extract VVIQ scores
for i = 1:numel(vviq_ID)
    vviq_score(i) = vviq.SCORE(vviq.CASE==vviq_ID(i));
end

% Assign groups
high = vviq_score > median(vviq_score);
low = vviq_score < median(vviq_score);

% Get scores for subjects in p
id_ind = find(ismember(mri_ID, p.subjects));
vviq_score = vviq_score(id_ind);
high = high(id_ind);
low = low(id_ind);

