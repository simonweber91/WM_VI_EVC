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

% Load questionnaire data
load(fullfile(p.base_dir,'Questionnaire', 'recruitment', 'VVIQ.mat'));
vviq = VVIQ.vviq;

% Apply exclusion criteria
vviq = vviq(vviq.INVITE~=3,:);
vviq = vviq(vviq.AGE<=45,:);
vviq = vviq(vviq.EXCL_CRITERIA==1,:);
vviq = vviq(vviq.HANDEDNESS==2,:);
vviq = vviq(vviq.BERLIN~=2,:);