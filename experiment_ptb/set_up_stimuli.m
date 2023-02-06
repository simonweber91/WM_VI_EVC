function Experiment = set_up_stimuli(Experiment)

% Set Up Stimuli
% Input: Struct 'Experiment' with fields 'mainPath', 'Display', 'Subject'
% Output: Struct 'Experiment' with field 'Present'
%     'Present' contains one field per run 'R[run]'
%     'R[run]' contain fields:
%         'Rand' - randomization info (order and seed)
%         'name' - name/ID of stimulus file/image
%         'data' - stimulus data
%         'present' - PTB handle for onscreen presentation
%
% For within and between run presentation, stimulus order is randomized
% according to a fully randomized latin square. Within each run, the same
% number of stimuli from each rating bin (see stimulus selection procedure)
% are presented.

% mainPath = Experiment.mainPath;
Display = Experiment.Display;

Stimulus = struct();

%% Grating
% Initial parameters to generate the grating:
% stimsize = 600;
stimsize = round(Display.yPixels*0.6);
% radius of the disc edge
radius = stimsize / 2;
% smoothing sigma in pixel
sigma = 150; % was 80
% use alpha channel for smoothing?
% useAlpha = true;
useAlpha = 1;
% smoothing method: cosine (0) or smoothstep (1)
smoothMethod = 0;

stimRect = SetRect(0, 0, stimsize, stimsize);
stimRect = CenterRect(stimRect, Display.windowRect);

% Stimulus texture - Procedural Smoothed Aperture Sine Grating
grating = CreateProceduralSmoothedApertureSineGrating(Display.window, stimsize, stimsize,...
  [0.5 0.5 0.5 0], radius, [], sigma, useAlpha, smoothMethod);
% Create Procedural Square Wave Grating
% grating = CreateProceduralSquareWaveGrating(Display.window, size, size,...
%           [.5 .5 .5 0], radius);

% Annulus Texture
annulusRect = SetRect(0,0, stimsize/6, stimsize/6);
annulusRect = CenterRect(annulusRect,Display.windowRect);

annulusDim = radius / 6;
[xm, ym] = meshgrid(-annulusDim:annulusDim, -annulusDim:annulusDim);
% Increase the central window and tighten the edge, to produce a smooth
% aperture
% annulusEdge = rescale(-((xm .^2) + (ym .^2)));
annulusEdge = -((xm .^2) + (ym .^2));
annulusEdge = (annulusEdge - min(annulusEdge(:)))/(max(annulusEdge(:)) - min(annulusEdge(:))); % alternative to rescale
annulusEdge(annulusEdge>0.9)=1;
annulusEdge(annulusEdge<0.5)=0;
% annulusEdge(~ismember(annulusEdge,[0,1]))=rescale(annulusEdge(~ismember(annulusEdge,[0,1])));
edge = annulusEdge(~ismember(annulusEdge,[0,1]));
annulusEdge(~ismember(annulusEdge,[0,1])) = (edge - min(edge(:)))/(max(edge(:))-min(edge(:)));
annulusEdge = abs(annulusEdge-1);
[s1, s2] = size(annulusEdge);
annulus = ones(s1, s2, 2) * Display.black;
annulus(:, :, 2) = Display.white * (1 - annulusEdge);
annulustex = Screen('MakeTexture', Display.window, annulus);


% Additional parameters to present the grating
phase = [0:180/3:180];
% spatial frequency in cycles per pixel
freq = .02;
contrast = 0.8;

Stimulus.size = stimsize;
Stimulus.radius = radius;
Stimulus.sigma = sigma;
Stimulus.useAlpha = useAlpha;
Stimulus.smoothMethod = smoothMethod;
Stimulus.phase = phase;
Stimulus.freq = freq;
Stimulus.contrast = contrast;
Stimulus.stimRect = stimRect;
Stimulus.grating = grating;
Stimulus.annulusRect = annulusRect;
Stimulus.annulustex = annulustex;

Experiment.Stimulus = Stimulus;

%% White noise mask

% maskType = 'grating';
maskType = 'white_noise';

% size of noise mask (rectangle of aperture)
maskSize = Stimulus.size;

% Compute destination rectangle locations for the random noise patches and
% center in Display.window
maskRect = SetRect(0,0, maskSize, maskSize);
maskRect = CenterRect(maskRect,Display.windowRect);

% Make an aperture with the "alpha" channel ("window" through which mask is
% seen)
appertureDim = maskSize / 2;
[xm, ym] = meshgrid(-appertureDim:appertureDim, -appertureDim:appertureDim);
% Increase the central window and tighten the edge, to produce a smooth
% aperture
% smoothEdge = rescale(-((xm .^2) + (ym .^2)));
smoothEdge = -((xm .^2) + (ym .^2));
smoothEdge = (smoothEdge - min(smoothEdge(:)))/(max(smoothEdge(:)) - min(smoothEdge(:))); % alternative to rescale
smoothEdge(smoothEdge>0.65)=1;
smoothEdge(smoothEdge<0.5)=0;
% smoothEdge(~ismember(smoothEdge,[0,1]))=rescale(smoothEdge(~ismember(smoothEdge,[0,1])));
edge = smoothEdge(~ismember(smoothEdge,[0,1]));
smoothEdge(~ismember(smoothEdge,[0,1])) = (edge - min(edge(:)))/(max(edge(:))-min(edge(:)));
% smoothEdge = abs(smoothEdge-1);
[s1, s2] = size(smoothEdge);
apperture = ones(s1, s2, 2) * Display.black;
apperture(:, :, 2) = Display.white * (1 - smoothEdge);
maskApperture = Screen('MakeTexture', Display.window, apperture);
            

Stimulus.maskType = maskType;
Stimulus.maskSize = maskSize;
Stimulus.maskRect = maskRect;
Stimulus.maskApperture = maskApperture;

%% 'Missed trial' cross

edge = 20;
radius = edge/2;

pointList = [Display.xCenter-radius Display.yCenter-radius;
    Display.xCenter+radius Display.yCenter-radius;
    Display.xCenter+radius Display.yCenter+radius;
    Display.xCenter-radius Display.yCenter+radius];

Stimulus.missedTrials.edge = edge;
Stimulus.missedTrials.radius = radius;
Stimulus.missedTrials.pointList = pointList;

%% Fixcross

fixSize = 2;

Stimulus.fixSize = fixSize;

%% Shift stimulus position

shiftX = 0;
shiftY = 0; %-Display.windowRect(4)/6;
shiftRect = [shiftX shiftY shiftX shiftY];

Stimulus.shiftRect = shiftRect;


%%

Experiment.Stimulus = Stimulus;

fprintf('stimulus ready.\n');

%% Legacy

%%% 1
% Stimulus annulus
% Annulus in the middle of the grating: smoothed apterture grating with 0
% contrast
% annulus = CreateProceduralSmoothedApertureSineGrating(Display.window, ceil(stimsize/6), ceil(stimsize/6),...
%   [0 0 0 0], ceil(radius/6), [], 45, useAlpha, smoothMethod); % was 15
% Stimulus.annulus = annulus;

%%% 2
% Mask texture
% Build a nice aperture texture: Offscreen windows can be used as
% textures as well, so we open an Offscreen window of exactly the same
% size 'objRect' as our noise textures, with a gray default background.
% This way, we can use the standard Screen drawing commands to 'draw'
% our aperture:
% mask = Screen('OpenOffscreenWindow', Display.window, Display.black);

% First we clear out the alpha channel of the aperture disk to zero -
% In this area the noise stimulus will shine through:
% Screen('FillOval', mask, [0 0 0 0]);

% Draw annulus around retro-cue
% Screen('FillOval', mask, Display.black, CenterRect(SetRect(0,0,maskSize/10,maskSize/10),objRect));
% Screen('DrawTexture', mask, Stimulus.annulus, [], [], 0,...
%                 [], 1, [], [], [], [0, Stimulus.freq, 0, 0]);
% Stimulus.mask = mask;