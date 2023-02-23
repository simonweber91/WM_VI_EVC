function recalibrate_eyetracker(Experiment)

Display = Experiment.Display;

if strcmp(Experiment.Mode.eyetracking,'Yes')
    
    el = EyelinkInitDefaults(Display.window);
    
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
    
end

end