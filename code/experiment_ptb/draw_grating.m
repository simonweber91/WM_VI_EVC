function vbl = draw_grating(Experiment, tilt, phase, fixcolor, flip, flipTime)

% requires 'tilt' and accepts 'phase' as additional argument. If 'phase' is
% not passed, it is set to 0 by default
% takes flipTime as additional argument to specify exact time of flip
% (script waits until time is reached)

Display = Experiment.Display;
Stimulus = Experiment.Stimulus;

if ~exist('tilt','var') || isempty(tilt)
    tilt = 0;
end

if ~exist('phase','var') || isempty(phase)
    phase = 0;
end

if ~exist('fixcolor','var') || isempty(fixcolor)
    fixcolor = [255,255,255];
end

Screen('DrawTexture', Display.window, Stimulus.grating, [], Stimulus.stimRect+Stimulus.shiftRect, tilt,...
    [], 1, [150 150 150], [], [], [phase, Stimulus.freq, Stimulus.contrast, 0]); % [175 175 175]
% Screen('DrawTexture', Display.window, Stimulus.annulus, [], [], 0,...
%     [], 1, [], [], [], [0, Stimulus.freq, 0, 0]);
Screen('DrawTexture', Display.window, Stimulus.annulustex, [], Stimulus.annulusRect+Stimulus.shiftRect);
% Screen('FillOval', Display.window, Display.black, CenterRect(SetRect(0,0,Stimulus.size/10,Stimulus.size/10),Display.windowRect));
Screen('DrawDots', Display.window, [Display.xCenter+Stimulus.shiftRect(1), Display.yCenter+Stimulus.shiftRect(2)], 10, fixcolor, [], Stimulus.fixSize);


% flip by default
if ~exist('flip','var') || isempty(flip)
    flip = 1;
end

% if flipTime not provided, flip immediately
if ~exist('flipTime','var') || isempty(flipTime)
    flipTime = 0;
end

if flip == 1
    vbl = Screen('Flip', Display.window, flipTime);
end
get_response(Experiment, 'exit');