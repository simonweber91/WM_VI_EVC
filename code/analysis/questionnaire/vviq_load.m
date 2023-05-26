function vviq = vviq_load(p)

% function vviq = vviq_load(p)
%
% Load data of the Vividness of Visual Imagery Questionnaire (Marks, 1975)
% used for recruitment for all participnats that met the inclusion
% criteria (i.e. the recruitment pool).
%
% Output:
%   - vviq: Table of questionnaire data.
%
% Simon Weber, sweber@bccn-berlin.de, 2021

vviq = [];

vviq_out = dir(fullfile(p.dirs.data, 'questionnaire', 'vviq.mat'));
if ~isempty(vviq_out) && ~p.OVERWRITE
    warning('vviq.mat already exists.');
    return;
end

% Load questionnaire data
vviq_file = fullfile(p.dirs.data, 'vviq', 'vviq_public.mat');
if ~exist(vviq_file, 'file')
    warning('vviq_public.mat not found. Please make sure that VVIQ.mat is stored in %s.', fullfile(p.dirs.data, 'vviq'))
    return;
end

load(vviq_file);
vviq = VVIQ.vviq;

% Apply exclusion criteria
vviq = vviq(vviq.INVITE~=3,:);
vviq = vviq(vviq.AGE<=45,:);
vviq = vviq(vviq.EXCL_CRITERIA==1,:);
vviq = vviq(vviq.HANDEDNESS==2,:);
vviq = vviq(vviq.BERLIN~=2,:);

save(fullfile(p.dirs.data, 'questionnaire', 'vviq.mat'), 'vviq')
