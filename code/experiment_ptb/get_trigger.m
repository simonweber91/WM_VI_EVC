function t0 = get_trigger(Experiment)

% Get Trigger
% Input: Struct 'Experiment' with fields 'Keys'
% Output: Time of first MRI trigger

Keys = Experiment.Keys;

keysOfInterest = zeros(1,256);
keysOfInterest(Keys.mriTrigger) = 1;
KbQueueCreate([],keysOfInterest);
KbQueueStart([]);
t0 = KbQueueWait([]);
KbQueueStop([]);
KbQueueFlush([]);