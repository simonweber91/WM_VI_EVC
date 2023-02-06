function vbl = draw_mask(Experiment, cue, flip, flipTime)

% takes 'cue' as additional argument to display a cue inside the mask when
% necessary
% takes 'flip' as additional argument. Default 1 (flip). Set to flip
% outside of script.
% takes flipTime as additional argument to specify exact time of flip
% (script waits until time is reached)

Display = Experiment.Display;
Stimulus = Experiment.Stimulus;

Screen('TextSize', Display.window, 40);

pixSize = 11;

% Creates a persistent variable "noiseimg" (1) (persists across multiple calls of
% the function, which allows for dynamic changing of the noise pattern).
% "noiseimg" consinst of 50/50 black and white pixels randomly distributed
% in the array (2). The indices of these pixels (position within the aray) are
% then randomly shifted up, down, left or right, to create the dynamic
% nature of the mask

persistent noiseimg     %(1)
if isempty(noiseimg)
    noiseimg = zeros(round(Stimulus.maskSize/pixSize));
    idx = randperm(numel(noiseimg));    %(2)
    idx = idx(1:round(numel(noiseimg)/2));
    noiseimg(idx) = 1;
end
idx = randperm(size(noiseimg,1));       %(3)
idx1 = idx(1:floor(size(noiseimg,1)/2));
idx2 = idx(floor(size(noiseimg,1)/2):end);
noiseimg(:,idx1) = circshift(noiseimg(:,idx1),1);
noiseimg(idx1,:) = circshift(noiseimg(idx1,:),1,2);
noiseimg(:,idx2) = circshift(noiseimg(:,idx2),-1);
noiseimg(idx2,:) = circshift(noiseimg(idx2,:),-1,2);

% Acturally not entirely sure how this came about, but this is responsible
% for the smoothing. I think I looked up "smoothing with moving average"
% somewhere and this came up.
maskimg = noiseimg;
winSize = 2; % size of moving window in conv
maskimg = conv2(maskimg, ones(winSize)/4 ,'same');
% for i = 1:size(maskimg,1)
%     maskimg(i,:) = conv(maskimg(i,:), ones(winSize,1)/winSize, 'same');
% end
% for j = 1:size(maskimg,2)
%     maskimg(:,j) = conv(maskimg(:,j), ones(winSize,1)/winSize, 'same');
% end
% This bit resized the image to fit the screen, adjusts the contrast and
% scales the values to fit the RGB color scheme used by Psychtoolbox
maskimg = imresize(maskimg,600/size(noiseimg,1));
maskimg = imadjust(maskimg,[0.1 0.9]);
maskimg = maskimg.*255;


% Convert it to a texture 'tex':
tex=Screen('MakeTexture', Display.window, maskimg);

% Draw the texture into the screen location defined by the
% destination rectangle 'dstRect(i,:)'. If dstRect is bigger
% than our noise image 'noiseimg', PTB will automatically
% up-scale the noise image. We set the 'filterMode' flag for
% drawing of the noise image to zero: This way the bilinear
% filter gets disabled and replaced by standard nearest
% neighbour filtering. This is important to preserve the
% statistical independence of the noise pixels in the noise
% texture! The default bilinear filtering would introduce local
% correlations when scaling is applied:
Screen('DrawTexture', Display.window, tex, [], Stimulus.maskRect+Stimulus.shiftRect, [], 0);

% Overdraw the rectangular noise image with our special
% aperture image. The noise image will shine through in areas
% of the aperture image where its alpha value is zero (i.e.
% transparent):
Screen('DrawTexture', Display.window, Stimulus.maskApperture, [], Stimulus.maskRect+Stimulus.shiftRect, [], 0);

% Screen('DrawTexture', Display.window, Stimulus.annulus, [], [], 0,...
%                 [], 1, [], [], [], [0, Stimulus.freq, 0, 0]);
Screen('DrawTexture', Display.window, Stimulus.annulustex, [], Stimulus.annulusRect+Stimulus.shiftRect);

% After drawing, we can discard the noise texture.
Screen('Close', tex);


% draw cue or fixation
if exist('cue','var') && ~isempty(cue)
	DrawFormattedText(Display.window, num2str(cue), Display.xCenter-10, Display.yCenter+Stimulus.shiftRect(2)+15, Display.white);  
	% DrawFormattedText(Display.window, num2str(cue), Display.xCenter-10, 'center', Display.white); % number centered on test screen, use 'centerblock' to use imprecise ptb centering
else
    Screen('DrawDots', Display.window, [Display.xCenter+Stimulus.shiftRect(1), Display.yCenter+Stimulus.shiftRect(2)], 10, [255,255,255], [], Stimulus.fixSize);
end

% flip by default
if ~exist('flip','var') || isempty(flip)
    flip = 1;
end

% if flipTime not provided, flip immediately
if ~exist('flipTime','var') || isempty(flipTime)
    flipTime = 0;
end

% Use this to slow down flicker
% WaitSecs(Display.ifi);

if flip == 1
    vbl = Screen('Flip', Display.window, flipTime);
end
get_response(Experiment, 'exit');


%% Legacy

%%% 1
% switch mask type

% switch Stimulus.maskType
%     
%     case 'grating'
%         
% Screen('DrawTexture', Display.window, Stimulus.grating, [], [], tilt,...
%     [], 1, [], [], [], [0, Stimulus.freq, Stimulus.contrast, 0]);
% Screen('DrawTexture', Display.window, Stimulus.grating, [], [], tilt+90,...
%     [], 0.5, [], [], [], [0, Stimulus.freq, Stimulus.contrast, 0]);
% % Screen('FillOval', Display.window, Display.black, CenterRect(SetRect(0,0,Stimulus.size/10,Stimulus.size/10),Display.windowRect));
% Screen('DrawTexture', Display.window, Stimulus.annulus, [], [], 0,...
%                 [], 1, [], [], [], [0, Stimulus.freq, 0, 0]);
%         
%     case 'white_noise'
% end

%%% 2
% noise img generation using smooth data
% noiseimg=(50*randn(Stimulus.maskSize/pixSize, Stimulus.maskSize/pixSize) + 128);

% noiseimg = randn(Stimulus.maskSize/pixSize);
% noiseimg = smoothdata(noiseimg);
% noiseimg = smoothdata(noiseimg,2);
% noiseimg = rescale(noiseimg);
% noiseimg = imadjust(noiseimg,[0.3 0.7]);
% noiseimg = noiseimg.*255;

% maskimg = zeros(Stimulus.maskSize/pixSize);
% idx = randperm(numel(maskimg));
% idx = idx(1:numel(maskimg)/2);
% maskimg(idx) = 1;
% for i = 1:2
%     maskimg = smoothdata(maskimg);
%     maskimg = smoothdata(maskimg,2);
% end
% maskimg = imadjust(maskimg,[0.2 0.8]);
% maskimg = maskimg.*255;

% This section uses smoothdata, which is not supported before Matlab 2017a
%{
for i = 1:2
    maskimg = smoothdata(maskimg);
    maskimg = smoothdata(maskimg,2);
end
maskimg = imresize(maskimg,600/size(noiseimg,1));
maskimg = imadjust(maskimg,[0.25 0.75]);
%}