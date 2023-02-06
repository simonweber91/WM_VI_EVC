commandwindow

close all; 
clearvars;
sca;

rng('shuffle');

mainPath = 'C:\Users\haynesuser\Desktop\visimg_simon\Main';
% mainPath = '/home/simon/Matlab/Projects/VisualImagery/Experiment';
% mainPath = '/home/sweber/Mind_Brain/VisualImagery/Experiment';
% mainPath = 'Z:\Mind_Brain\VisualImagery\Experiment';

Localizer = struct();

Localizer.mainPath = mainPath;

clear filesep mainPath

%% Set up Subject

% answer = questdlg('Load subject from file?', 'Load subject', 'Yes', 'No','Cancel','Cancel');
answer = input('Load subject from file? Y/N.  ','s');
answer = lower(answer);
switch answer
    case {'yes','y'}
        ok = [];
        while ~strcmp(ok,'y')
            [logf,logp] = uigetfile(Localizer.mainPath);
            Mainlog = open(fullfile(logp,logf));
            Subjectlog = Mainlog.Experiment.Subject;
    %         defaults = {'VisualImagery', Subjectlog.id, Subjectlog.age, Subjectlog.sex, Subjectlog.group, Subjectlog.language};
            fprintf(['\nSubject ID: ' Subjectlog.id]);
            fprintf(['\nAge: ' Subjectlog.age]);
            fprintf(['\nSex: ' Subjectlog.sex]);
            fprintf(['\nGroup: ' Subjectlog.group]);
            fprintf(['\nLanguage: ' Subjectlog.language '\n']);
            ok = input('\nContinue? Y/N.  ','s'); ok = lower(ok);
        end
        id = Subjectlog.id;
        age = Subjectlog.age;
        sex = Subjectlog.sex;
        group = Subjectlog.group;
        language = Subjectlog.language;
    case {'no','n'}
%         defaults = {'VisualImagery', '', '', '', '', ''};
        ok = [];
        while ~strcmp(ok,'y')
            id = input('Subject ID:  ', 's');
            age = input('Age:  ','s');
            sex = input('Sex:  ','s');
            group = input('Group:  ','s');
            language = input('Language: DE/EN.  ','s'); language = upper(language);
            ok = input('\nContinue? Y/N.  ','s'); ok = lower(ok);
        end
    case 'cancel'
        return;
end
% prompt = {'TitleOfStudy', 'Subject ID', 'Age', 'Sex', 'Group', 'Language'};
% [studyTitle, id, age, sex, group, language] = deal(defaults{:});
% answer = inputdlg(prompt, 'VisualImagery', 2, defaults);
% [studyTitle, id, age, sex, group, language] = deal(answer{:});
% while isempty(id) || isempty(age) || isempty(sex) || isempty(group) || isempty(language)
%     % Set participant info for output file using input prompt
%     prompt = {'TitleOfStudy', 'Subject ID', 'Age', 'Sex', 'Group', 'Language'};
%     defaults = {'VisualImagery', id, age, sex, group, language};
%     answer = inputdlg(prompt, 'VisualImagery', 2, defaults);
%     [studyTitle, id, age, sex, group, language] = deal(answer{:}); % all input variables are strings
%     if ~strcmp(language,'EN') && ~strcmp(language,'DE')
%         fprintf(['Language code not valid:\n',...
%             'Use ''DE'' for german or ''EN'' for english.\n']);
%     end
% end

logPath = fullfile(Localizer.mainPath,['sub_' id],'log');
if exist(logPath,'dir') == 0
    mkdir(logPath)
end

outFile = fullfile(logPath,['sub_' id '_log_localizer_' datestr(now,'yymmddHHMM')]);

% Check to avoid overiding an existing file
if exist([outFile,'.mat']) == 2 || exist([outFile,'.xls']) == 2
    fileproblem = input('Output files already exist! OVERWRITE (1/DEFAULT), or break (2)?');
    if fileproblem == 2
        return;
    elseif isempty(fileproblem) | fileproblem == 1
        delete([outFile, '.mat']);
        delete([outFile, '.xls']);
    end
end 

Subject = struct();
Subject.id = id;
Subject.age = age;
Subject.sex = sex;
Subject.group = group;
Subject.language = language;
Subject.path = logPath;
Subject.out = outFile;

Localizer.Subject = Subject;

%% Set up Display

externalScreen = 0;
% [0 0 1024 768]
% Define black and white
white = WhiteIndex(externalScreen);
black = BlackIndex(externalScreen);
grey = white / 2; 
Screen('Preference', 'SkipSyncTests', 2);
% [window,  windowRect] = Screen('OpenWindow',0,[],[1920 1200-768 1920+1366 1200]);
[window,  windowRect] = Screen('OpenWindow',externalScreen);

% Backgroud color
Screen('FillRect', window , grey);

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

Localizer.Display = Display;

%% Set up Stimuli

mainPath = Localizer.mainPath;

stimFiles = dir(fullfile(mainPath,'Files','Localizer','loc*'));

for iStim = 1:numel(stimFiles)
    name = stimFiles(iStim).name;
    file = fullfile(mainPath,'Files','Localizer', stimFiles(iStim).name);
    Stimulus.(name).data = imread(file);
    Stimulus.(name).handle = Screen('MakeTexture', Display.window, Stimulus.(name).data);
end

Stimulus.fixSize = 2;

Localizer.Stimulus = Stimulus;

% Screen('DrawTexture', Display.window, Stimulus.loc_horz_1.handle, [], [], 0);
% vbl = Screen('Flip', Display.window);

%% Set up Keys

KbName('UnifyKeyNames');

Keys.mriTrigger = KbName('5%');
Keys.escKey = KbName('ESCAPE');

Keys.spaceKey = KbName('space');
Keys.returnKey = KbName('Return');
Keys.controlKeys = [Keys.spaceKey, Keys.returnKey];

Keys.one = KbName('1!');
Keys.two = KbName('2@');
Keys.three = KbName('3#');
Keys.four = KbName('4$');
Keys.responseKeys = [Keys.one, Keys.two, Keys.three, Keys.four];
% HID NAR 12345

Localizer.Keys = Keys;

%% Set up Timing

Timing.frameFreq = round(1/Display.ifi);
Timing.flicker = 1/8;
Timing.flickerFrames = ceil(Timing.flicker/Display.ifi);

Timing.stimulus = 12;
Timing.iti = 4;

% Timing.stimulus = 1;
% Timing.iti = 1;

% Set up run
nTrials = 20;

timing = repmat([Timing.iti; Timing.stimulus], nTrials*2, 1);
timing = cumsum(timing);
timing = reshape(timing, [4,nTrials])';

Timing.timing = timing;

Localizer.Timing = Timing;

%% Set up Log

% Initialize Log table
varNames = {'Trial','Horizontal','FIX_1','RESP_1','ITI_1','Vertical','FIX_2','RESP_2','ITI_2'};
% varTypes = {'string','string','string','double','double','string','double'};
varTypes = {0,0,0,0,0,0,0,0,0};
% Log = table('Size',[0 numel(varNames)],'VariableTypes',varTypes,'VariableNames',varNames);
log = cell2table(varTypes,'VariableNames',varNames);
log(1,:) = [];

Localizer.Log = log;

%% Run

% show text
Screen('TextSize', Display.window, 25);
[nx, ny, bbox] = DrawFormattedText(Display.window, 'Waiting for scanner...', 'centerblock','center', Display.white, [], 0, [], 1.25);
Screen('Flip', Display.window);

% Start run manually before starting scanner
fprintf('\n\nPress SPACE or RETURN to start retinotopy\n\n');
get_response(Localizer,'control');

% get MRI trigger
keysOfInterest = zeros(1,256);
keysOfInterest(Keys.mriTrigger) = 1;
KbQueueCreate([],keysOfInterest);
KbQueueStart([]);
t0 = KbQueueWait([]);
KbQueueStop([]);
KbQueueFlush([]);

stims = fieldnames(Stimulus);

i = 1;
fixColor = 1; 
Screen('DrawDots', Display.window, [Display.xCenter, Display.yCenter], 10, Display.white, [], Stimulus.fixSize);
vbl = Screen('Flip', Display.window);
% t0 = vbl;
output = fprintf('\nTrial 0/%d', nTrials);
for iTrial = 1:nTrials
    
    fprintf(repmat('\b',1,output));
    output = fprintf('\nTrial &d/%d', iTrial, nTrials);
    
    % horizontal stimulation
    flicker = timing(iTrial,1):Timing.flicker:timing(iTrial,2);
    changeFix = flicker(randi(length(flicker)-9));
    idx = 1;
    response = NaN;
    for iFlick = flicker(1:end-1)
        
        if iFlick == changeFix
            fixColor = 0;
        elseif flicker(find(flicker==changeFix)+4)
            fixColor = 1;
        end
        
        if idx == 1
            Screen('DrawTexture', Display.window, Stimulus.(stims{1}).handle, [], [], 0);
            idx = 2;
        elseif idx == 2
            Screen('DrawTexture', Display.window, Stimulus.(stims{2}).handle, [], [], 0);
            idx = 1;
        end
        
        if fixColor == 1
            Screen('DrawDots', Display.window, [Display.xCenter, Display.yCenter], 10, Display.white, [], Stimulus.fixSize);
        elseif fixColor == 0
            Screen('DrawDots', Display.window, [Display.xCenter, Display.yCenter], 10, Display.black, [], Stimulus.fixSize);
        end
        
        vbl = Screen('Flip', Display.window, t0+iFlick);
        % log onset
        if iFlick == timing(iTrial,1)
            tHorz = vbl-t0;
        elseif iFlick == changeFix
            fix1 = vbl-t0;
        end
        
        if isnan(response)
            response = localizer_response(Localizer);
            if ~isnan(response)
                resp1 = vbl-t0;
            else
                resp1 = NaN;
            end
        end
        
        exit_localizer(Localizer)
    end
    
    
    % ITI
    Screen('DrawDots', Display.window, [Display.xCenter, Display.yCenter], 10, Display.white, [], Stimulus.fixSize);
    vbl = Screen('Flip', Display.window, t0+timing(iTrial,2));
    iti1 = vbl-t0;
    
    
    % vertical stimulation
    flicker = timing(iTrial,3):Timing.flicker:timing(iTrial,4);
    changeFix = flicker(randi(length(flicker)-9));
    idx = 1;
    response = NaN;
    for iFlick = flicker(1:end-1)
        
        if iFlick == changeFix
            fixColor = 0;
        elseif flicker(find(flicker==changeFix)+4)
            fixColor = 1;
        end
        
        if idx == 1
            Screen('DrawTexture', Display.window, Stimulus.(stims{3}).handle, [], [], 0);
            idx = 2;
        elseif idx == 2
            Screen('DrawTexture', Display.window, Stimulus.(stims{4}).handle, [], [], 0);
            idx = 1;
        end
        
        if fixColor == 1
            Screen('DrawDots', Display.window, [Display.xCenter, Display.yCenter], 10, Display.white, [], Stimulus.fixSize);
        elseif fixColor == 0
            Screen('DrawDots', Display.window, [Display.xCenter, Display.yCenter], 10, Display.black, [], Stimulus.fixSize);
        end
        
        vbl = Screen('Flip', Display.window, t0+iFlick);
        % log onset
        if iFlick == timing(iTrial,3)
            tVert = vbl-t0;
        elseif iFlick == changeFix
            fix2 = vbl-t0;
        end
        
        if isnan(response)
            response = localizer_response(Localizer);
            if ~isnan(response)
                resp2 = vbl-t0;
            else
                resp2 = NaN;
            end
        end
        
        exit_localizer(Localizer)
    end
    
    
     % ITI
    Screen('DrawDots', Display.window, [Display.xCenter, Display.yCenter], 10, Display.white, [], Stimulus.fixSize);
    vbl = Screen('Flip', Display.window, t0+timing(iTrial,4));
    iti2 = vbl-t0;
     
    % fill log file
    Localizer.Log(end+1,:) = table(iTrial, tHorz, fix1, resp1, iti1, tVert, fix2, resp2, iti2);
    
end

vbl = Screen('Flip', Display.window, vbl+Timing.iti);

% Save and close
save([Localizer.Subject.out,'.mat'],'Localizer');
ShowCursor;
Screen('CloseAll');
