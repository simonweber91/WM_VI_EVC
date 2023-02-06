function vbl = draw_fixcross(Experiment, color, flip, flipTime)

% takes color as additional argument to allow feedback, default color is
% white
% takes flipTime as additional argument to specify exact time of flip
% (script waits until time is reached)

Stimulus = Experiment.Stimulus;
Display = Experiment.Display;

if ~exist('color','var') || isempty(color)
    color = [255,255,255];
end

Screen('DrawDots', Display.window, [Display.xCenter+Stimulus.shiftRect(1), Display.yCenter+Stimulus.shiftRect(2)], 10, color, [], Stimulus.fixSize);

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