function dat = filter_eye(dat, p)

% Filter the gaze data according to "Thielen, J., van Lier, R., & van
% Gerven, M. (2018). No evidence for confounding orientation-dependent
% fixational eye movements under baseline conditions. Scientific reports,
% 8(1), 1-10." using a low pass butterworth filter of 5th order with 100 Hz
% cutoff.

fo = 5;    % filter order
fc = 100;  % cut off frequency
fs = p.eye.hz; % recording frequncy of data

[b,a] = butter(fo, fc / fs, 'low');
dat.gazex = filtfilt(b, a, dat.gazex);
dat.gazey = filtfilt(b, a, dat.gazey);

