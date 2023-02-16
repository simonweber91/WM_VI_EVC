%% --------------------------------------------------------------------
%                       Initial setup
%----------------------------------------------------------------------

addpath('/.../VisualImagery_paper/experiment_ptb')

% This experiment is implemented via Psychtoolbox-3. Instructions on how to
% donwload, install and set up Psychtoolbox for your operating system can
% be found here: http://psychtoolbox.org/download
addpath('/.../ptb_location')

commandwindow
close all; clearvars; sca;
rng('shuffle');

%%% Set main directody
% Should contain the Folder 'Introduction' with instruction slides.
% For each subject, a folder will be  created where log-files are stored.

mainPath = '/.../visimg_experiment';

%%%

Experiment = struct();

% Experiment.Mode.mode = 'test';
Experiment.Mode.mode = 'experiment';

% use eyetracker?
if strcmp(Experiment.Mode.mode, 'experiment')
    et = input('Eyetracking? Y/N.  ','s');
    et = lower(et);
    switch et
        case{'yes','y'}
            Experiment.Mode.eyetracking = 'Yes';
        case{'no','n'}
            Experiment.Mode.eyetracking = 'No';
        otherwise
            error('Unexpected input');
            return;
    end
else
    Experiment.Mode.eyetracking = [];
end

Experiment.mainPath = mainPath;

clear tasks response indx filesep mainPath

%% --------------------------------------------------------------------
%                       Subject setup
%----------------------------------------------------------------------

Experiment = set_up_subject(Experiment);


%% --------------------------------------------------------------------
%                       Display setup
%----------------------------------------------------------------------

% Input for set_up_display, use 1 input only:
% 'test' to run test mode (opens separate window on 2 screen system, change
%       resolution from within the function.
% numeric value to specify the index of the external screen that should be
%       used for presentation.
Experiment = set_up_display(Experiment);

%% --------------------------------------------------------------------
%                       Stimulus setup
%----------------------------------------------------------------------

Experiment = set_up_stimuli(Experiment);


%% --------------------------------------------------------------------
%                       Trial setup
%----------------------------------------------------------------------

% Experiment = set_up_trial(Experiment);


%% --------------------------------------------------------------------
%                       Timing Information
%----------------------------------------------------------------------

Experiment = set_up_timing(Experiment);


%% --------------------------------------------------------------------
%                       Keyboard information
%----------------------------------------------------------------------

Experiment = set_up_keys(Experiment);


%% --------------------------------------------------------------------
%                       Make Design
%----------------------------------------------------------------------

nRuns = 4;
nTrials = 40;

if isfield(Experiment.Mode,'Resume')
    nRuns = nRuns-Experiment.Mode.Resume.run+1;
end

Experiment = set_up_design(Experiment, nRuns, nTrials);


%% --------------------------------------------------------------------
%                      Run experiment
%----------------------------------------------------------------------

Experiment = run_vwm(Experiment);        


%% --------------------------------------------------------------------
%                      Safe log, end
%----------------------------------------------------------------------

fprintf('\nDONE');
draw_text(Experiment,'done');

% Write out Logfile and delete temp_log
save_log(Experiment);
delete([Experiment.Subject.out,'_temp.mat']);

fprintf('\nLogfile saved.\n');
fprintf('\n- - - Press any button to end the experiment. - - -\n');

get_response(Experiment, 'continue');

% End
ShowCursor;
Screen('CloseAll');
