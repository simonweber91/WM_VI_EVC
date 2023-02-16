function Experiment = set_up_keys(Experiment)

% Set Up Keys
% Input: Struct 'Experiment'
% Output: Struct 'Experiment' with field 'Keys'
%   'Keys' contains fields for each key that has a function during the
%       experiment, the MRI trigger, as well as a list of the keys used to
%       respond during the experiment.

KbName('UnifyKeyNames'); 
Keys.spaceKey = KbName('space');
Keys.returnKey = KbName('Return');
Keys.escKey = KbName('ESCAPE');
Keys.leftArrow = KbName('LeftArrow');
Keys.rightArrow = KbName('RightArrow');

Keys.mriTrigger = KbName('5%');

Keys.nButtons = 4;
Keys.one = KbName('1!');
Keys.two = KbName('2@');
Keys.three = KbName('3#');
Keys.four = KbName('4$');
% HID NAR 12345

Keys.responseKeys = [Keys.one, Keys.two, Keys.three, Keys.four, Keys.leftArrow, Keys.rightArrow, Keys.spaceKey];
Keys.controlKeys = [Keys.spaceKey, Keys.returnKey];

Experiment.Keys = Keys;