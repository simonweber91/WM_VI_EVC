function set_up_eyetracker(Experiment)

% Felix T???pfer 250219
% based on
% ~\Psychtoolbox\PsychHardware\EyelinkToolbox\EyelinkDemos\SR-ResearchDemo\EyeLinkPicture
% IN: 
% - DisplayRefNum = reference number of the presentation screen 
% - xResolution = resolution of x axis of the screen (nr of pixels)
% - yResolution = resolution of y axis of the screen (nr of pixels)
% -> please read Screen('OpenWindow') discribtion of psychtoolbox if you do not know
% how to obtain these values

if strcmp(Experiment.Mode.eyetracking,'Yes')

Display = Experiment.Display;
Subject = Experiment.Subject;

 dummymode=0;
 
try 
% set the name of the eye data file that will store the recorded data
% maximum number of digits:8
%     edfFile = ['sub_' Subject.id '_log_main_' datestr(now,'yymmddHHMM')];
    edfFile = [Subject.id '_' datestr(now,'HHMM')];
% tell the name to the experimenter
%     fprintf('EDFFile: %s\n', edfFile );

    % STEP 3
    % Provide Eyelink with details about the graphics environment
    % and perform some initializations. The information is returned
    % in a structure that also contains useful defaults
    % and control codes (e.g. tracker state bit and Eyelink key values).
    el = EyelinkInitDefaults(Display.window);

    % STEP 4
    % Initialization of the connection with the Eyelink Gazetracker.
    % exit program if this fails.
    if ~EyelinkInit(dummymode)
        fprintf('Eyelink Init aborted.\n');
        cleanup;  % cleanup function
        return;
    end

    % the following code is used to check the version of the eye tracker
    % and version of the host software
    sw_version = 0;

    [v vs]=Eyelink('GetTrackerVersion');
    fprintf('Running experiment on a ''%s'' tracker.\n', vs );

    % open file to record data to
    i = Eyelink('Openfile', edfFile);
    if i~=0
        fprintf('Cannot create EDF file ''%s'' ', edffilename);
        Eyelink( 'Shutdown');
        Screen('CloseAll');
        return;
    end

%     Eyelink('command', 'add_file_preamble_text ''Recorded by EyelinkToolbox demo-experiment''');
%     
%     [width, height]=Screen('WindowSize', screenNumber);


    % STEP 5    
    % SET UP TRACKER CONFIGURATION
    % Setting the proper recording resolution, proper calibration type, 
    % as well as the data file content;
    Eyelink('command','screen_pixel_coords = %ld %ld %ld %ld', 0, 0, Display.xPixels-1, Display.yPixels-1);
    Eyelink('message', 'DISPLAY_COORDS %ld %ld %ld %ld', 0, 0, Display.xPixels-1, Display.yPixels-1);                
    % set calibration type.
    Eyelink('command', 'calibration_type = HV9');
    % set calibration target to be at 50% of the screen
    Eyelink('command', 'calibration_area_proportion 0.5 0.5');
    Eyelink('command', 'validation_area_proportion 0.5 0.5');
    % set parser (conservative saccade thresholds)

    % set EDF file contents using the file_sample_data and
    % file-event_filter commands
    % set link data thtough link_sample_data and link_event_filter
    Eyelink('command', 'file_event_filter = LEFT,RIGHT,FIXATION,SACCADE,BLINK,MESSAGE,BUTTON,INPUT');
    Eyelink('command', 'link_event_filter = LEFT,RIGHT,FIXATION,SACCADE,BLINK,MESSAGE,BUTTON,INPUT');

    % check the software version
    % add "HTARGET" to record possible target data for EyeLink Remote
    if sw_version >=4
        Eyelink('command', 'file_sample_data  = LEFT,RIGHT,GAZE,GAZERES,HREF,AREA,STATUS,INPUT');
        Eyelink('command', 'link_sample_data  = LEFT,RIGHT,GAZE,GAZERES,AREA,STATUS,INPUT');
    else
        Eyelink('command', 'file_sample_data  = LEFT,RIGHT,GAZE,GAZERES,HREF,AREA,STATUS,INPUT');
        Eyelink('command', 'link_sample_data  = LEFT,RIGHT,GAZE,GAZERES,AREA,STATUS,INPUT');
    end

    % allow to use the big button on the eyelink gamepad to accept the 
    % calibration/drift correction target
    Eyelink('command', 'button_function 5 "accept_target_fixation"');
    
    % allow online drift correct to fixed location
    Eyelink('command', 'driftcorrect_cr_disable = OFF');
    Eyelink('command', 'online_dcorr_refposn %d,%d', Display.xCenter, Display.yCenter);
    Eyelink('command', 'online_dcorr_button = ON');
    Eyelink('command', 'normal_click_dcorr = OFF');
    Eyelink('command', 'key_funktion F9 "online_dcorr_trigger"');
    Eyelink('command', 'online_dcorr_maxangle = %d', 5);
   
    
    % make sure we're still connected.
    if Eyelink('IsConnected')~=1 && dummymode == 0
        fprintf('not connected, clean up\n');
        Eyelink( 'Shutdown');
        Screen('CloseAll');
        return;
    end



    % STEP 6
    % Calibrate the eye tracker
    % setup the proper calibration foreground and background colors
    el.backgroundcolour = [0 0 0];
    el.calibrationtargetcolour = [170 170 170];

    % parameters are in frequency, volume, and duration
    % set the second value in each line to 0 to turn off the sound
    el.cal_target_beep=[600 0.5 0.05];
    el.drift_correction_target_beep=[600 0.5 0.05];
    el.calibration_failed_beep=[400 0.5 0.25];
    el.calibration_success_beep=[800 0.5 0.25];
    el.drift_correction_failed_beep=[400 0.5 0.25];
    el.drift_correction_success_beep=[800 0.5 0.25];
    % you must call this function to apply the changes from above
    EyelinkUpdateDefaults(el);

    % Hide the mouse cursor;
    Screen('HideCursorHelper', Display.window);
    EyelinkDoTrackerSetup(el);
    
    
catch
     %this "catch" section executes in case of an error in the "try" section
     %above.  Importantly, it closes the onscreen window if its open.
%      Eyelink('ShutDown');
%      Screen('CloseAll');
%      commandwindow;
%      rethrow(lasterr);
end %try..catch.

end

    