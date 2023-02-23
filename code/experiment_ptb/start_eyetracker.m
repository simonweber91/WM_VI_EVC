function start_eyetracker(Experiment)

if strcmp(Experiment.Mode.eyetracking,'Yes')
    % start recording eye position (preceded by a short pause so that 
    % the tracker can finish the mode transition)
    % The paramerters for the 'StartRecording' call controls the
    % file_samples, file_events, link_samples, link_events availability
    Eyelink('Command', 'set_idle_mode');
    WaitSecs(0.05);

    % record a few samples before we actually start displaying
    % otherwise you may lose a few msec of data 
    Eyelink('StartRecording');    

    WaitSecs(0.1);
end
        
end