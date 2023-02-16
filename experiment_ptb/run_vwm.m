function Experiment = run_vwm(Experiment)

% Run Experiment
% Input: Struct 'Experiment' with fields 'Subject', 'Display', 'Stimulus', 'Timing', 'Keys'
% Output: Struct 'Experiment' with updated field 'Subject.Log'


nRuns = Experiment.Design.nRuns;

mainPath = Experiment.mainPath;
Mode = Experiment.Mode;
Subject = Experiment.Subject;
Display = Experiment.Display;
Stimulus = Experiment.Stimulus;
Timing = Experiment.Timing;
Keys = Experiment.Keys;

if strcmp(Experiment.Mode.eyetracking,'Yes'), et = 1; else, et = 0; end

% set up eyetracker
if et == 1
    Screen('TextSize', Display.window, 25);
	DrawFormattedText(Display.window, 'Eyetracker setup...', 'center', 'center', Display.white);
    Screen('Flip', Display.window);
    fprintf('\n\nPress SPACE or RETURN to set up eyetracker\n\n');
    get_response(Experiment,'control');
end
set_up_eyetracker(Experiment);

% welcome screen
fprintf('\nWelcome Screen');
draw_text(Experiment,'welcome');

% instructions
fprintf('\nInstructions');
draw_text(Experiment,'i*_vwm');

% Training run
if strcmp(Mode.training,'Yes')
    Experiment = run_vwm_training(Experiment);
elseif isempty(Mode.training) || strcmp(Mode.training,'No') 
end

fprintf('\nReady screen');
draw_text(Experiment,'ready');

for iRun = 1:nRuns
    
    Experiment.Log.currentRun = iRun;
    Experiment.Log.currentTrial = 0;
    
    nTrials = Experiment.Design.Run(iRun).nTrials;
    
    % Wait for subject to continue
    if iRun ~= 1
        fprintf('\nBreak screen');
        draw_text(Experiment,'break');
    end
    draw_text(Experiment,'waiting', 0);
    
    % recalibrate eyetracker
    recal = input('\nRecalibrate eyetracking? Y/N.  ','s');
    recal = lower(recal);
    switch recal
        case{'yes','y'}
            recalibrate_eyetracker(Experiment);
        otherwise
            fprintf('\nContinue without recalibration');
    end
    
    % Start run manually before starting scanner
    fprintf('\n\n   !!! Press SPACE or RETURN to start run !!!   \n\n');
    get_response(Experiment,'control');
    
    % Start recording eyetracking data
    fprintf(['\nstart eyetracker']);
    start_eyetracker(Experiment);
    
    % get trigger, assign t0
    fprintf('\n\nSTART SCANNER\n\n');
    t0 = get_trigger(Experiment);
    Experiment.Log.Run(iRun).table(end+1,:) = table({Subject.id},{Subject.group},iRun,NaN,{'mri_start'},NaN,t0);
    
%     fprintf(['\nStarting run ' num2str(iRun)]);
%     fprintf('\nTrial\tStimPos\tStimTilt\tRespTilt\tAccuracy');

    output = fprintf('\nrun %d/%d - trial: 0, correct: 0, missed: 0', iRun, nRuns);
    
    % Loop through stimuli
    correct = 0;
    missed = 0;
    for iTrial = 1:nTrials
        
        fprintf(repmat('\b',1,output));
        output = fprintf('run %d/%d - trial: %d, correct: %d, missed: %d', iRun, nRuns, iTrial, correct, missed);

        % Present fixation cross before first trial
        if iTrial == 1
            vbl = draw_fixcross(Experiment, [], 1, t0);
            vbl = draw_fixcross(Experiment, Display.grey, 1, t0+Timing.itiMean);
        end 
        
        % Print trial number to command window
%         fprintf(['\ntrial ' num2str(iTrial)]);

        Experiment.Log.currentTrial = iTrial;

        Experiment = present_trial_vwm(Experiment);
        
        response = Experiment.Log.Run(iRun).table.value(end-1);
        if isnan(response)
            missed = missed+1;
        else
            correct = correct+1;
        end
        fprintf(repmat('\b',1,output));
        output = fprintf('run %d/%d - trial: %d, correct: %d, missed: %d', iRun, nRuns, iTrial, correct, missed);
        
    end

% stop eyetracker
stop_eyetracker(Experiment);
% Save log file
save_log(Experiment);

end

end_eyetracker(Experiment);


%% Legacy

%%% 1
% Switch between tasks and response methods
% switch Experiment.Task.task
%     case 'vwm_behavior'
%         nRuns = 3;
%         nTrials = 48;
%         
%         offset = [0:3:15]';
%     case 'vwm_mri'
%         nRuns = 4;
%         nTrials = 40;
%         
%         if strcmp(Experiment.Task.response, '2afc')
%             offsetYn = input('offset = 5 (1, default) or load file (2)?');
%             if isempty(offsetYn)|| offsetYn == 1
%                 offset = 5;
%             elseif offsetYn == 2
%                 logfiles = dir([Subject.path, '/vwm_behavior*.mat']);
%                 logfiles = {logfiles.name};
%                 % choice in ui or command window
%                 switch Experiment.mode
%                     case 'test'
%                         for i = 1:numel(logfiles)
%                             disp(logfiles{i});
%                         end
%                         loadfile = input('Which file should be loaded?', 's');  
%                     case 'experiment'
%                         indx = listdlg('ListString', logfiles, 'PromptString', 'Select file to load', 'SelectionMode', 'single', 'InitialValue', numel(logfiles));
%                         loadfile = logfiles{indx};
%                 end
%                 % Load individual threshold from behavior log
%                 offset = load(fullfile(Subject.path,loadfile));
%                 offset = offset.Experiment.questInfo.tFinal;
%             %     offset = (round(offset*2)/2); % round to closest 0.5 step
%                 offset = round(offset,2);
%             end 
%         % quick and dirty solution for missing offset in delayed estimation
%         % paradigm
%         elseif strcmp(Experiment.Task.response, 'delayed_estimation')
%             offset = 5;
%         end
% end

%%% 2
% some eyetracking switch, probably obsolete
% if strcmp(Task.eyetracking, 'Yes')
%     Experiment = present_trial_vwm_et(Experiment);
% else
%     Experiment = present_trial_vwm(Experiment);
% end

%%% 3
% get t0
% switch Experiment.Task.task
%     case 'vwm_behavior'
%         t0 = GetSecs();
%         Experiment.Log.(['R' num2str(iRun)])(end+1,:) = table({Subject.id},{Subject.group},iRun,NaN,{'behavior_start'},NaN,t0);
%     case 'vwm_mri'
%         draw_text(Experiment,'waiting', 0);
%         fprintf('\nSubject ready, start run.\n');
%         t0 = get_trigger(Experiment);
%         Experiment.Log.(['R' num2str(iRun)])(end+1,:) = table({Subject.id},{Subject.group},iRun,NaN,{'mri_start'},NaN,t0);
% end

%%% 4
% offset for 2afc variant
% offset = 5;
% Experiment = set_up_run(Experiment, iRun, nTrials, offset);
