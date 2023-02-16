function Experiment = set_up_timing(Experiment)

% Set Up Timing
% Input: Struct 'Experiment' with fields 'Display'
% Output: Struct 'Experiment' with field 'Timing'
%     'Timing' contains fields: 'waitSecs' - number of seconds to wait
%     after certain operations 'frameFeq' - screen refresh frequency
%     'imageSecs' - number of seconds of stimulus/image presentation
%     'imageFrames' - number of frames of stimulus/image presentation
%     'ratingFreq' - frequency of sampling of ratings 'sampleFrames' -
%           vector containing the indices of frames that should be sampled

Display = Experiment.Display;

% Interval before/after instruction screens
Timing.waitSecs = 0.5;

% Numer of frames to wait before re-drawing
Timing.frameFreq = round(1/Display.ifi);

% How long should the image stay up in time and frames
Timing.stimulus = 0.4;
Timing.stimulusFrames = round(Timing.stimulus / Display.ifi);

% delay between stimuli in retro-cued design
Timing.mask = 0.4;
Timing.maskFrames = round(Timing.mask / Display.ifi);

% Presentation of cue in retro-cued design in secs and frames
Timing.cue = 0.4;
Timing.cueFrames = round(Timing.cue / Display.ifi);

% Delay period in seconds and frames
Timing.delay = 10;
% Timing.delay = 0.5;
Timing.delayFrames = round(Timing.delay / Display.ifi);

% Probe timing in seconds and frames
Timing.probe = 0.4;
Timing.probeFrames = round(Timing.probe / Display.ifi);
        
% Response period in seconds and frames
Timing.response = 2.4;
Timing.responseFrames = round(Timing.response / Display.ifi);

% Feedback timing in seconds and frames
Timing.feedback = 0.4;
Timing.feedbackFrames = round(Timing.feedback / Display.ifi);

% How long should the inter trial interval be in seconds and frames
Timing.itiMean = 3.6;
Timing.itiJitter = 1.6;
Timing.itis = [Timing.itiMean-Timing.itiJitter, Timing.itiMean, Timing.itiMean+Timing.itiJitter];

% Timing for trial cue (grey fixcross)
Timing.trialcue = 0.4;
Timing.trialcueFrames = round(Timing.trialcue / Display.ifi);


Experiment.Timing = Timing;


%% Legacy

%%% 1
% rotation design
% Timing.stimulus = 2; % --> rotation design

% % Frequency of stimulus flicker in Hz --> rotation design
% Timing.flickerFreq = 3;
% Timing.flickerFrames = round((1/(Timing.flickerFreq)) / Display.ifi);

%%% 2
% VMI rating
% Rating period (vmi) in frames and seconds
Timing.rating = 3;
Timing.ratingFrames = round(Timing.rating / Display.ifi);
