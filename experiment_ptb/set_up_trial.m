function Experiment = set_up_trial(Experiment)

events = {'grating1', 'mask1', 'grating2', 'mask2', 'cue', 'delay',...
    'probe', 'response', 'feedback', 'iti', 'trialCue'};

Experiment.Trial.events = events;