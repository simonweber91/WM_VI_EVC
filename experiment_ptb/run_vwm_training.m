function Experiment = run_vwm_training(Experiment)

Subject = Experiment.Subject;
Display = Experiment.Display;

%% Instructions and example trial

% Timing and trial parameters
itiExample = 2.5;
trialCueExample = 0.5;
stimExample = 2;
maskExample = 2;
cueExample = 2;
delayExample = 6;
respExample = 3;

probeExample = 6;

stimTilt = 0;
distTilt = 90;

textSize = 30;
textLoc = Display.yPixels*0.7;

response = [];

fprintf('\nTraining - ');
draw_text(Experiment,'example');

Screen('TextSize', Display.window, textSize);
while isempty(response) || response ~= 1 || isnan(response)
    response = [];

    switch Subject.language
        case 'EN'
            text = {'fixate the dot','first grating','second grating','cue: remember first grating','remember grating','rotate with right hand and log in with left hand','press left or right arrow button','very good!','try again','missed'};
        case 'DE'
            text = {'Punkt fixieren','erstes Gitter','zweites Gitter','Hinweis: erstes Gitter merken','Gitter merken','Mit rechter Hand rotieren, mir linker Hand einloggen','linken oder rechten Pfeil druecken','sehr gut!','nochmal versuchen','verpasst'};
    end

    % Draw fixation cross
    draw_fixcross(Experiment, [], 0);
    DrawFormattedText(Display.window, text{1}, 'center', textLoc, Display.white);
    vbl = Screen('Flip', Display.window);
    % Trial cue
    draw_fixcross(Experiment, Display.grey, 0);
    DrawFormattedText(Display.window, text{1}, 'center', textLoc, Display.white);
    vbl = Screen('Flip', Display.window, vbl+itiExample);
    % grating 1
    draw_grating(Experiment, stimTilt, 0, [], 0);
    DrawFormattedText(Display.window, text{2}, 'center', textLoc, Display.white);
    vbl = Screen('Flip', Display.window, vbl+trialCueExample);
    % mask 1
    vbl = draw_mask(Experiment, [], 1, vbl+stimExample);
    while GetSecs < vbl+maskExample-Display.ifi
        draw_mask(Experiment);
    end
    % grating 2
    Screen('TextSize', Display.window, textSize);
    draw_grating(Experiment, distTilt, 0, [], 0);
    DrawFormattedText(Display.window, text{3}, 'center', textLoc, Display.white);
    vbl = Screen('Flip', Display.window, vbl+maskExample);
    % mask 2
    vbl = draw_mask(Experiment, [], 1, vbl+stimExample);
    while GetSecs < vbl+maskExample-Display.ifi
        draw_mask(Experiment);
    end
    % cue
    draw_mask(Experiment, 1, 0);
	Screen('TextSize', Display.window, textSize);
    DrawFormattedText(Display.window, text{4}, 'center', textLoc, Display.white);
    vbl = Screen('Flip', Display.window, vbl+maskExample);
    while GetSecs < vbl+cueExample-Display.ifi
        draw_mask(Experiment, 1, 0);
        Screen('TextSize', Display.window, textSize);
        DrawFormattedText(Display.window, text{4}, 'center', textLoc, Display.white);
        Screen('Flip', Display.window);
    end
    % delay
    draw_fixcross(Experiment, [], 0);
    DrawFormattedText(Display.window, text{5}, 'center', textLoc, Display.white);
    vbl = Screen('Flip', Display.window, vbl+cueExample);

    % probe
    Screen('TextSize', Display.window, textSize);
    probeTilt = 45;
    draw_grating(Experiment, probeTilt, 0, [], 0);
    DrawFormattedText(Display.window, text{6}, 'center', textLoc, Display.white);
    vbl = Screen('Flip', Display.window, vbl+delayExample);
    while GetSecs < vbl+probeExample
    
        draw_grating(Experiment, probeTilt, 0, [], 0);
        DrawFormattedText(Display.window, text{6}, 'center', textLoc, Display.white);
        Screen('Flip', Display.window);
        
        response = get_response(Experiment, 'continuous');
        % Log in answer (otherwise: responseTilt is NaN)
        if response == -9999
            draw_grating(Experiment, probeTilt, 0, [0,255,0], 0);
            DrawFormattedText(Display.window, text{6}, 'center', textLoc, Display.white);
            Screen('Flip', Display.window);
            break;
        end
        probeTilt = probeTilt + response;
        if probeTilt <= 0 
            probeTilt = 360;
        elseif probeTilt >= 360
            probeTilt = 0;
        end
    end
    responseTilt = probeTilt;
    if response == -9999
        if responseTilt > 180
            responseTilt = responseTilt - 180;
        end
        response = responseTilt-stimTilt;
        if response > 90
            response = response-180;
        elseif response < -90
            response = response+180;
        end
    else
        response = NaN;
    end
    if isnan(response)
        draw_missed(Experiment, 0);
        DrawFormattedText(Display.window, text{10}, 'center', textLoc, Display.white);
        vbl = Screen('Flip', Display.window, vbl+probeExample);
        fprintf('missed - ');
    elseif abs(response) < 10
        draw_fixcross(Experiment, [], 0);
        DrawFormattedText(Display.window, text{8}, 'center', textLoc, Display.white);
        vbl = Screen('Flip', Display.window, vbl+probeExample);
        fprintf('correct');
        response = 1;
    elseif abs(response) > 10
        draw_fixcross(Experiment, [], 0);
        DrawFormattedText(Display.window, text{9}, 'center', textLoc, Display.white);
        vbl = Screen('Flip', Display.window, vbl+probeExample);
        fprintf('incorrect - ');
    end
    
    WaitSecs(stimExample);

end


%% trial runs

nTrials = 6;

Training = Experiment;
Training.Design = [];
Training.Log = [];
Training = set_up_design(Training, 1, nTrials);

Training.Log.currentRun = 1;

trialInfo = Training.Design.Run(1).trialInfo;
timingInfo = Training.Design.Run(1).timingInfo;

draw_text(Experiment,'training');

t0 = GetSecs();
Training.Log.Run(1).table(end+1,:) = table({Subject.id},{Subject.group},1,NaN,{'training_start'},NaN,t0);

fprintf(['\nStarting training run\n']);
   
% Loop through stimuli
output = fprintf('\ntraining run - trial: 0, correct: 0, missed: 0');
correct = 0;
missed = 0;
for iTrial = 1:nTrials
    
    fprintf(repmat('\b',1,output));
    output = fprintf('training run - trial: %d, correct: %d, missed: %d', iTrial, correct, missed);
    
    % Print trial number to command window
%     fprintf(['\n' num2str(iTrial)]);

    if iTrial == 1
        vbl = draw_fixcross(Training, [], 1, t0);
        vbl = draw_fixcross(Training, Display.grey, 1, t0+Training.Timing.itiMean);
    end 

    Training.Log.currentTrial = iTrial;

    Training = present_trial_vwm(Training);
    
    response = Training.Log.Run(1).table.value(end-1);
    if isnan(response)
        missed = missed+1;
    else
        correct = correct+1;
    end
    fprintf(repmat('\b',1,output));
    output = fprintf('training run - trial: %d, correct: %d, missed: %d', iTrial, correct, missed);
    
end

Experiment.Design.Training = Training.Design.Run(1);
Experiment.Log.Training.table = Training.Log.Run(1).table;

%% Legacy

%%% 1
% Text 2afc
%             text = {'fixate the dot','first grating','second grating','cue: remember first grating','remember grating','comparison: clockwise or anticlockwise?','press left or right arrow button','correct','false','missed'};
%             text = {'Punkt fixieren','erstes Muster','zweites Muster','Hinweis: erstes Muster merken','Muster merken','Vergleich: im oder gegen Uhrzeigersinn?','linken oder rechten Pfeil druecken','richtig','falsch','verpasst'};

%%% 2
% switch between response methods

% switch Experiment.Task.response
%     
%     case 'delayed_estimation'       
%     case '2afc'   
%     
%     % probe
%     Screen('TextSize', Display.window, textSize);
%     draw_grating(Experiment, 45, 0, [], 0);
%     DrawFormattedText(Display.window, text{6}, 'center', Display.yPixels*0.2, Display.white);
%     vbl = Screen('Flip', Display.window, vbl+delayExample);
%     while GetSecs < vbl+stimExample
%         if isempty(response)
%             response = get_response(Experiment, 'binary');
%         end
%     end
%     % response
%     draw_fixcross(Experiment, [], 0);
%     DrawFormattedText(Display.window, text{7}, 'center', Display.yPixels*0.2, Display.white);
%     vbl = Screen('Flip', Display.window, vbl+stimExample);
%     while GetSecs < vbl+stimExample
%         if isempty(response)
%             response = get_response(Experiment, 'binary');
%         end
%     end
%     %feedback
%     if response == 1
%         draw_fixcross(Experiment, [0,255,0], 0);
%         DrawFormattedText(Display.window, text{8}, 'center', Display.yPixels*0.2, Display.white);
%         vbl = Screen('Flip', Display.window, vbl+respExample);
%         disp('correct');
%     elseif response == -1
%         draw_fixcross(Experiment, [255,0,0], 0);
%         DrawFormattedText(Display.window, text{9}, 'center', Display.yPixels*0.2, Display.white);
%         vbl = Screen('Flip', Display.window, vbl+respExample);
%         disp('incorrect');
%     elseif isempty(response)
%         draw_missed(Experiment, 0);
%         DrawFormattedText(Display.window, text{10}, 'center', Display.yPixels*0.2, Display.white);
%         vbl = Screen('Flip', Display.window, vbl+stimExample);
%         disp('missed');
%     end
%     
% end    

%%% 2
% below draw mask to get dynamic white noise
%     if strcmp(Stimulus.maskType, 'white_noise')
%         while GetSecs < vbl+maskExample-Display.ifi
%             draw_mask(Experiment, maskTilt);
%         end
%     end