function Experiment = present_trial_vwm(Experiment)


Subject = Experiment.Subject;
Display = Experiment.Display;
Stimulus = Experiment.Stimulus;
Timing = Experiment.Timing;
Keys = Experiment.Keys;
Design = Experiment.Design;
Log = Experiment.Log;

iRun = Log.currentRun;
iTrial = Log.currentTrial;

trialInfo = Design.Run(iRun).trialInfo;
timingInfo = Design.Run(iRun).timingInfo;

stimTilt = trialInfo.stimulus(iTrial);
stimPos = trialInfo.stimPos(iTrial);
distTilt = trialInfo.distractor(iTrial);
probeTilt = trialInfo.probe(iTrial);

t0 = Experiment.Log.Run(iRun).table.timing(1);

if strcmp(Experiment.Mode.eyetracking,'Yes'), et = 1; else, et = 0; end

response = [];
% Present stimuli
switch stimPos
    case 1
        tilt = [stimTilt, distTilt];
        event = {'stimulus', 'distractor'};
    case 2
        tilt = [distTilt, stimTilt];
        event = {'distractor', 'stimulus'};
end

% fprintf(['\t' num2str(stimPos)]);
% fprintf(['\t' num2str(stimTilt)]);

% first grating
vbl = draw_grating(Experiment, tilt(1), 0, [], 1, t0+timingInfo.grating1(iTrial));
Experiment.Log.Run(iRun).table(end+1,:) = table({Subject.id},{Subject.group},iRun,iTrial,event(1),tilt(1),vbl - t0);
if et, Eyelink('Message', 'trial %d', iTrial); end

% mask
vbl = draw_mask(Experiment, [], 1, t0+timingInfo.mask1(iTrial));
if strcmp(Stimulus.maskType, 'white_noise')
    while GetSecs < vbl+Timing.mask-Display.ifi
        draw_mask(Experiment);
    end
end

% second grating
vbl = draw_grating(Experiment, tilt(2), 0, [], 1, t0+timingInfo.grating2(iTrial));
Experiment.Log.Run(iRun).table(end+1,:) = table({Subject.id},{Subject.group},iRun,iTrial,event(2),tilt(2),vbl - t0);

% mask
vbl = draw_mask(Experiment, [], 1, t0+timingInfo.mask2(iTrial));
if strcmp(Stimulus.maskType, 'white_noise')
    while GetSecs < vbl+Timing.mask-Display.ifi
        draw_mask(Experiment);
    end
end

% cue
vbl = draw_mask(Experiment, stimPos, 1, t0+timingInfo.cue(iTrial));
Experiment.Log.Run(iRun).table(end+1,:) = table({Subject.id},{Subject.group},iRun,iTrial,{'retrocue'},stimPos,vbl - t0);
if strcmp(Stimulus.maskType, 'white_noise')
    while GetSecs < vbl+Timing.stimulus-Display.ifi
        draw_mask(Experiment, stimPos);
    end
end

% delay
vbl = draw_fixcross(Experiment, [], 1, t0+timingInfo.delay(iTrial));
Experiment.Log.Run(iRun).table(end+1,:) = table({Subject.id},{Subject.group},iRun,iTrial,{'delay'},NaN,vbl - t0);
if et, Eyelink('Message', 'delay', iTrial); end

% probe and response
vbl = draw_grating(Experiment, probeTilt, 0, [], 1, t0+timingInfo.probe(iTrial));
if et, Eyelink('Message', 'response', iTrial); end

while GetSecs < t0+timingInfo.iti(iTrial)-Display.ifi
    draw_grating(Experiment, probeTilt, 0);
    response = get_response(Experiment, 'continuous');
    % Log in answer (otherwise: responseTilt is NaN)
    if response == -9999
        rt = GetSecs();
        draw_grating(Experiment, probeTilt, 0, [0,255,0]);
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

% relate responses to original stimulus orientations, assign NaN
% when no log in occured
if responseTilt > 180
    responseTilt = responseTilt - 180;
end

if response == -9999
    response = responseTilt-stimTilt;

    if response > 90
        response = response-180;
    elseif response < -90
        response = response+180;
    end
else
    response = NaN;
end

Experiment.Log.Run(iRun).table(end+1,:) = table({Subject.id},{Subject.group},iRun,iTrial,{'probe'},responseTilt,vbl - t0);
Experiment.Log.Run(iRun).table(end+1,:) = table({Subject.id},{Subject.group},iRun,iTrial,{'response'},response,GetSecs - t0);

% fprintf(['\t' num2str(responseTilt)]);
% fprintf(['\t' num2str(response)]);

% ITI
if isnan(response)
    vbl = draw_missed(Experiment, 1, t0+timingInfo.iti(iTrial));
    draw_fixcross(Experiment, [], 1, vbl+Timing.feedback);
else
    vbl = draw_fixcross(Experiment, [], 1, t0+timingInfo.iti(iTrial));
end
Experiment.Log.Run(iRun).table(end+1,:) = table({Subject.id},{Subject.group},iRun,iTrial,{'iti'},NaN,vbl - t0);
vbl = draw_fixcross(Experiment, Display.grey, 1, t0+timingInfo.trialCue(iTrial));
        

save([Subject.out,'_temp.mat'],'Experiment');


%% Legacy

%%% 1
% probe offset, switch between response schemes
% switch Experiment.Task.response
%     case '2afc'
%         probeOffset = trialInfo.probeOffset(iTrial);
%         probeTilt = stimTilt+probeOffset;
%     case 'delayed_estimation'
%         % probe orientation for delayed estiomation paradigm
%         probeTilt = trialInfo.probe(iTrial);
% end

%%% 2
% switch between response schemes in experiment
% switch Experiment.Task.response
%     
%     case 'delayed_estimation' 
%     case '2afc'
%         
%         %%% probe + response %%%        
%         vbl = draw_grating(Experiment, probeTilt, phase(1), [], 1, t0+timingInfo.probe(iTrial));
%         probeOnset = vbl - t0; % to calculate RT
%         Experiment.Log.(['R' num2str(iRun)])(end+1,:) = table({Subject.id},{Subject.group},iRun,iTrial,{'probe'},probeTilt,vbl - t0);
% 
%         while GetSecs < t0+timingInfo.response(iTrial)-Display.ifi % ommit last frame to improve timing
%             % get response
%             if isempty(response)
%                 response = get_response(Experiment, 'binary');
%                 % get RT
%                 if ~isempty(response)
%                     responseTime = GetSecs - t0;
%                 end
%             end
%             get_response(Experiment, 'exit');
%         end
% 
%         % response
%         vbl = draw_fixcross(Experiment, [], 1, t0+timingInfo.response(iTrial));
% 
%         while GetSecs < t0+timingInfo.feedback(iTrial)-Display.ifi % ommit last frame to improve timing
%             if isempty(response)
%                 response = get_response(Experiment, 'binary');
%                 % get RT
%                 if ~isempty(response)
%                     responseTime = GetSecs - t0;
%                 end
%             end
%             get_response(Experiment, 'exit');
%         end
% 
%         % in case of no response, assign NaN and get max RT
%         if ~isempty(response)
%             if response == trialInfo.probeOffsetDir(iTrial)
%                 response = 1;
%             else
%                 response = 0;
%             end
%             reactionTime = responseTime - probeOnset;
%         elseif isempty(response)
%             response = NaN;
%             responseTime = NaN;
%             reactionTime = NaN;
%         end
%         % writes reaction time to "value"
%         Experiment.Log.(['R' num2str(iRun)])(end+1,:) = table({Subject.id},{Subject.group},iRun,iTrial,{'response'},reactionTime,responseTime);
% 
%         % display RT
% %         fprintf(['RT: ', num2str(Experiment.Log.(['R' num2str(iRun)]).timing(end)-Experiment.Log.(['R' num2str(iRun)]).timing(end-1))]);
% 
%         % feedback
%         if ~isnan(response)
%             if response == 1
%                 color = [0,255,0];
%                 disp('correct');
%             elseif response == 0
%                 color = [255,0,0];
%                 disp('incorrect');
%             else
%                 color = Display.white;
%             end
%             vbl = draw_fixcross(Experiment, color, 1, t0+timingInfo.feedback(iTrial));
%             % logs actual response (correct= 1/incorrect = 0/missed = NaN)
%             Experiment.Log.(['R' num2str(iRun)])(end+1,:) = table({Subject.id},{Subject.group},iRun,iTrial,{'feedback'},response,vbl - t0);
% 
%         elseif isnan(response)
%             vbl = draw_missed(Experiment, 1, t0+timingInfo.feedback(iTrial));
%             Experiment.Log.(['R' num2str(iRun)])(end+1,:) = table({Subject.id},{Subject.group},iRun,iTrial,{'feedback'},response,vbl - t0);
%             disp('missed');
%         end
%         
%         % ITI
%         vbl = draw_fixcross(Experiment, [], 1, t0+timingInfo.iti(iTrial));
%         Experiment.Log.(['R' num2str(iRun)])(end+1,:) = table({Subject.id},{Subject.group},iRun,iTrial,{'iti'},NaN,vbl - t0);
%         vbl = draw_fixcross(Experiment, Display.grey, 1, t0+timingInfo.trialCue(iTrial));
%         
% end
