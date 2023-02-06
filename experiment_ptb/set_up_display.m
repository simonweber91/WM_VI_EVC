function Experiment = set_up_display(Experiment)

% Set Up Display
% Input: Struct 'Experiment' with fields 'mode'
% Output: Struct 'Experiment' with field 'Display'
%   'Display' contains fields:
%         'nScreen' - list of available output screens
%         'externalScreen' - screen where expeiment is displayed
%         'white'/'black'/'grey' - values of white/black/grey
%         'window' - index of window in which experiment is displayed
%         'windowRect' - resolution of window
%         'xPixels'/'yPixels' - number of pixles in x/y direction of window
%         'xCenter'/'yCenter' - location of center pixel in x/y direction
%         'ifi' - inter frame interval, refresh rate

if isfield(Experiment.Mode, 'mode')
    mode = Experiment.Mode.mode;
else
    fprintf('\n\n\Error in Experiment.mode\n');
    fprintf('Use Experiment.mode = ''test'' to run test mode in onscreen window.\n');
    fprintf('Use Experiment.mode = ''experiment'' to run experiment on an external screen (see set_up_display.m).\n');
end

% Define external screen for presentation. Change according to setup.
% externalScreen = 0;
externalScreen = 2;

% Check mode. For 'test', run experiment in specified window.
% For 'experiment', run experiment on the external screen defined above.
if strcmp(mode,'test')
    fprintf('\n\n\nRun in test mode on separate window.\nChange resolution from within set_up_display.m\n\n\n')
    % Override externalScreen and use separate window on main screen (0)
    externalScreen = 0;
    % Define black and white
    white = WhiteIndex(externalScreen);
    black = BlackIndex(externalScreen);
    grey = white / 2; 
    Screen('Preference', 'SkipSyncTests', 2);
    [window,  windowRect] = Screen('OpenWindow',0,[],[0 0 1024 768]);  % lab:[0 0 1280 1200] / [1280 0 3200 1200] / [1280 0 2560 1024] & [0 0 1280 1024]
elseif strcmp(mode,'experiment')
    % Use externalScreen as defined at the top
    % Define black and white
    white = WhiteIndex(externalScreen);
    black = BlackIndex(externalScreen);
    grey = white / 2; 
    Screen('Preference', 'SkipSyncTests', 2 );
    [window, windowRect] = PsychImaging('OpenWindow', externalScreen, black);       
end

% Backgroud color
Screen('FillRect', window , black);

nScreen = Screen('Screens');

% Get the size of the onscreen window
[xPixels, yPixels] = Screen('WindowSize', window);

% Query the frame duration
ifi = Screen('GetFlipInterval', window);

% Query the maximum priority level
% topPriorityLevel = MaxPriority(window);    

% Get the centre coordinate of the window
[xCenter, yCenter] = RectCenter(windowRect);

Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

Display = struct();
Display.nScreen = nScreen;
Display.externalScreen = externalScreen;
Display.white = white;
Display.black = black;
Display.grey = grey;
Display.window = window;
Display.windowRect = windowRect;
Display.xPixels = xPixels;
Display.yPixels = yPixels;
Display.xCenter = xCenter;
Display.yCenter = yCenter;
Display.ifi = ifi;

Experiment.Display = Display;
