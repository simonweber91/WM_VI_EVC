function draw_text(Experiment, whichText, response)

% Draw Text
% Input: Struct 'Experiment' with fields 'Display', string 'drawText' with
% text.
% Gets flipped on screen directly.

mainPath = Experiment.mainPath;
Display = Experiment.Display;
Subject = Experiment.Subject;

if ~exist('response','var') || isempty(response)
    response = 1;
end

Files = dir(fullfile(mainPath,'Files','Introduction',[Subject.language,'*',whichText,'*']));
Files = {Files.name};

for iFile = 1:numel(Files)
    data = imread(fullfile(mainPath,'Files','Introduction',Files{iFile}));
%     introData = imresize(introData,Display.yPixels/size(introData,1));
    handle = Screen('MakeTexture', Display.window, data);
    Screen('DrawTexture', Display.window, handle, [], [], 0);
    vbl = Screen('Flip', Display.window);
    if response == 1
        get_response(Experiment,'continue');
    end
end

%% Legacy

%%% 1 
% draw PTB text
% % Screen('FillRect', Display.window ,Display.black); % defined in set_up_display
% Screen('TextSize', Display.window, 25);
% [nx, ny, bbox] = DrawFormattedText(Display.window, whichext, 'centerblock','center', Display.white, [], 0, [], 1.25);
% % Screen('FrameRect', Display.window, 0, bbox); % draws box around text
% Screen('Flip', Display.window);