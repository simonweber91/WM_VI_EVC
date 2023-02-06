function vbl = draw_missed(Experiment, flip, flipTime)

% takes flipTime as additional argument to specify exact time of flip
% (script waits until time is reached)

Display = Experiment.Display;
Stimulus = Experiment.Stimulus;

pointList = Stimulus.missedTrials.pointList;
pointList(:,1) = pointList(:,1)+Stimulus.shiftRect(1);
pointList(:,2) = pointList(:,2)+Stimulus.shiftRect(2);

Screen('DrawLine', Display.window , Display.white, pointList(1,1), pointList(1,2), pointList(3,1), pointList(3,2), 5);
Screen('DrawLine', Display.window , Display.white, pointList(2,1), pointList(2,2), pointList(4,1), pointList(4,2), 5);

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