function Experiment = set_up_run(Experiment, nRuns, nTrials)


Timing = Experiment.Timing;

Experiment.RunInfo.nRuns = nRuns;

for iRun = 1:nRuns
    
    
%% STIMULUS ORIENTATION

% Stimulus orientation randomization init
% number of bins
nBins = 8;
if rem(nTrials, nBins) ~= 0
    error(['nTrials has to b a multiple of nBins']);
else
    binReps = nTrials/nBins;
end
% nTrial discrete, equally spaced orientations
del = 180/nTrials; 
orientations = (del/2):del:180;

stimulusOrientations = shuffle(orientations);
distractorOrientations = shuffle(orientations) + (del/2);
probeOrientations = shuffle(orientations);

% BIN SOLUTION
%{
% determine upper boundry of upper bin
upperBinBoundry = 180-(180/nBins)/2;
% assign orientations larger than upperBinBoundry to first bin (offset to
% left of 0 degrees)... 
shiftby = length(find(orientations>upperBinBoundry));
orientations = circshift(orientations,shiftby);
% ...and give them negative (close to zero) values instead of high positive
% orientations(find(orientations>upperBinBoundry)) = orientations(find(orientations>upperBinBoundry))-180;
% determine indices of bin boundries for randomization
binBoundryIndices = 1:binReps:nTrials;

% Randomize stimulus orientation for each run
% randomize order of bins 
% repetition of each bin
binOrder = randomize_conditions(1:nBins,nTrials);
distrOrder = randomize_conditions(1:nBins,nTrials);
maskOrder = randomize_conditions(1:nBins,nTrials);
probeOrder = randomize_conditions(1:nBins,nTrials);

%%% VAR 1: 40 DISCRETE ORIENTATIONS
for i = 1:nBins
    if i < nBins
        stimulusOrientations(find(binOrder==i)) = shuffle(orientations(binBoundryIndices(i):binBoundryIndices(i+1)-1));
        distractorOrientations(find(distrOrder==i)) = shuffle(orientations(binBoundryIndices(i):binBoundryIndices(i+1)-1));
        maskOrientations(find(maskOrder==i)) = shuffle(orientations(binBoundryIndices(i):binBoundryIndices(i+1)-1));
        % probe orientation for delayed estimation paradigm
        probeOrientations(find(probeOrder==i)) = shuffle(orientations(binBoundryIndices(i):binBoundryIndices(i+1)-1));
    elseif i == nBins
        stimulusOrientations(find(binOrder==i)) = shuffle(orientations(binBoundryIndices(i):end));
        distractorOrientations(find(distrOrder==i)) = shuffle(orientations(binBoundryIndices(i):end));
        maskOrientations(find(maskOrder==i)) = shuffle(orientations(binBoundryIndices(i):end));
        probeOrientations(find(probeOrder==i)) = shuffle(orientations(binBoundryIndices(i):end));
    end
end
%}

%% TRIAL RANDOMIZATION

trial = 1:nTrials;

% Trial randomization init
% Counterbalances stimulus position with distractor position
% Counterbalancing of stimulus position and directional bins
% is not possible within one run and is therefore left at random.
stimPos = [repmat(1,1,nTrials/2), repmat(2,1,nTrials/2)]';
stimPos = shuffle(stimPos);

% determine distractor position from stimulus postition
distPos = abs(stimPos-2)+1; 

% Preallocate ITIs for entire run such as their mean is the predefined
% ITI value. If required by the number of trials, the predefined value
% is overrepresented.
itis = repmat(Timing.itis,1,floor(nTrials./numel(Timing.itis)));
itis = [itis, repmat(Timing.itiMean,1,rem(nTrials,numel(Timing.itis)))];
itis = shuffle(itis)';

%% LOG TABLE

% Initialize Log table
varNames = {'subjectID','group','runNumber','trialNumber','event','value','timing'};
% varTypes = {'string','string','string','double','double','string','double'};
varTypes = {'string','string',0,0,'string',0,0};
% Log = table('Size',[0 numel(varNames)],'VariableTypes',varTypes,'VariableNames',varNames);
log = cell2table(varTypes,'VariableNames',varNames);
log(1,:) = [];

%% IDEAL TIMING

% pre-calcualte ideal timing of run to detect potential inconsistencies in
% actual run
events = {'grating1', 'mask1', 'grating2', 'mask2', 'cue', 'delay',...
    'probe', 'response', 'feedback', 'iti', 'trialCue'};
durations = [Timing.stimulus, Timing.mask, Timing.stimulus, Timing.mask, Timing.cue, Timing.delay,...
    Timing.probe, Timing.response, Timing.feedback, Timing.itiMean, Timing.trialcue];


for iTrial = 1:nTrials

    if iTrial == 1
        timing = Timing.itiMean+Timing.trialcue;
    end

    for iEvent = 1:numel(events)
        if strcmp(events(iEvent),'iti')
            timing = [timing;timing(end)+(itis(iTrial))];
        else
            timing = [timing;timing(end)+durations(iEvent)];
        end
    end
end

timingInfo.table = table(sort(repmat(1:nTrials,1,numel(events)))', repmat(cellstr(events'),nTrials,1), timing(1:end-1), 'VariableNames', {'trial', 'event', 'timing'});

for iEvent = 1:numel(events)
    
    timingInfo.(events{iEvent}) = timingInfo.table.timing(strcmp(timingInfo.table.event, events{iEvent}));
    
end

%% CPMBINE INFO

RunInfo.nTrials = nTrials;
% create table
RunInfo.trialInfo = table(trial', stimulusOrientations', stimPos, distractorOrientations', distPos, probeOrientations', itis, 'VariableNames', {'trial', 'stimulus', 'stimPos', 'distractor', 'distPos', 'probe', 'itis'});

RunInfo.timingInfo = timingInfo;

% Assign RunInfo to Experiment, extra treatment for training trials
Experiment.RunInfo.Run(iRun) = RunInfo;
Experiment.Log.Run(iRun).table = log;

end

% Save log file
save_log(Experiment);


%% Legacy

%%% 1
% Stimulus orientations
%{
%%% VAR 2: offset in each bin RANDLOMLY DRAWN FROM UNIFORM DISTRIBUTION
bins = 0:180/nBins:180;
bins = bins(1:nBins);
% possible offset range towards in degrees to the left and right of bin
% center
range = floor(mean(diff(bins)));
offsetRand = randi([-range/2,range/2],1,nTrials);
orientations = binOrder+offsetRand;
%}

%%% 2
% ideal timing
% switch Experiment.Task.task
%     case {'vwm_behavior', 'vwm_mri'}
%         events = {'grating1', 'mask1', 'grating2', 'mask2', 'cue', 'delay',...
%             'probe', 'response', 'feedback', 'iti', 'trialCue'};
%         durations = [Timing.stimulus, Timing.mask, Timing.stimulus, Timing.mask, Timing.cue, Timing.delay,...
%             Timing.probe, Timing.response, Timing.feedback, Timing.itiMean, Timing.trialcue];
%     case 'vmi'
%         events = {'grating1', 'mask1', 'grating2', 'mask2', 'cue', 'delay',...
%             'rating', 'iti', 'trialCue'};
%         durations = [Timing.stimulus, Timing.mask, Timing.stimulus, Timing.mask, Timing.cue, Timing.delay,...
%             Timing.rating, Timing.itiMean, Timing.trialcue];
% end

%%% 3
% create table
% switch Experiment.Task.task
% case {'vwm_behavior', 'vwm_mri'}, switch Experiment.Task.response
%     case '2afc'
%         RunInfo.trialInfo = table(trial, stimulusOrientations', stimPos, distractorOrientations', distPos, probeOffsetDir, probeOffset, maskOrientations', itis, 'VariableNames', {'trial', 'stimulus', 'stimPos', 'distractor', 'distPos','probeOffsetDir', 'probeOffset', 'mask', 'itis'});
%     case 'delayed_estimation'
%         RunInfo.trialInfo = table(trial, stimulusOrientations', stimPos, distractorOrientations', distPos, probeOrientations', maskOrientations', itis, 'VariableNames', {'trial', 'stimulus', 'stimPos', 'distractor', 'distPos', 'probe', 'mask', 'itis'});
%     end
% case 'vmi'
%      RunInfo.trialInfo = table(trial, stimulusOrientations', stimPos, distractorOrientations', distPos, maskOrientations', itis, 'VariableNames', {'trial', 'stimulus', 'stimPos', 'distractor', 'distPos', 'mask', 'itis'});
% end

%%% 4
% offset for 2afc variant
% adjust for repmat
% if size(offset,2) > 1
%     offset = offset';
% end
% probeOffsetDir = repmat(repelem([1 -1],nTrials/4),1,2)';
% multiply repeated offsetThreshold vector with offsetDir to determine
% vector with final probe offsets and directions
% probeOffset = repmat(offset,nTrials/length(offset),1).*probeOffsetDir;
% Randomize trial order
% randomized 1:nTrials vector to determine order of trials
% trial = randperm(nTrials)';
% creates matrix with all conditions and sorts along random trial
% vector
% order = sortrows([trial, stimPos, probeOffsetDir, probeOffset]);
% order = sortrows([trial, stimPos]);
% split up matrix
% trial = order(:,1);
% stimPos = order(:,2);
% probeOffsetDir = order(:,3);
% probeOffset = order(:,4);
