function stop_eyetracker(Experiment)

if strcmp(Experiment.Mode.eyetracking,'Yes')
    WaitSecs(0.1);
    % stop the recording of eye-movements for the current trial
    Eyelink('StopRecording');
end
