function Experiment = set_up_subject(Experiment)

% Set Up Subject
% Input: Struct 'Experiment' with fields 'mainPath'
% Output: Struct 'Experiment' with field 'Subject'
%   'Subject' contains fields:
%       'id' - subject ID <- from input prompt
%       'age' - age of subject <- from input prompt
%       'group' - experimental group <- from input prompt
%       'nRuns' - number of runs <- from input prompt
%       'path' - path to subject directory <- created in main path
%       'out' - prefix ouf subject specific output files <- assembled from
%           subject information
%       'Log' - Log struct, containing tables for every run with variables
%           'SubjectID','Age','Group','RunNumber','TrialNumber',
%           'PictureID','Rating','Timing' <- created during experiment

mainPath = Experiment.mainPath;

% request participant information
switch Experiment.Mode.mode
    case 'test'
        id = 'test';
        session = '1';
        age = '21';
        sex = 'female';
        group = 'high';
        language = 'EN';
        
        ok = [];
        while ~strcmp(ok,'y')
            fprintf(['\nSubject ID: ' id]);
            fprintf(['\nSession: ' session]);
            fprintf(['\nAge: ' age]);
            fprintf(['\nSex: ' sex]);
            fprintf(['\nGroup: ' group]);
            fprintf(['\nLanguage: ' language '\n']);
            ok = input('\nContinue? Y/N.  ','s'); ok = lower(ok);
        end
        
%         defaults = {'VisualImagery', 'test', '21', 'female', 'high', 'EN'};
%         [studyTitle, id, age, sex, group, language] = deal(defaults{:});
%         % Set participant info for output file using input prompt
%         prompt = {'TitleOfStudy', 'Subject ID', 'Age', 'Sex', 'Group', 'Language'};
%         defaults = {'VisualImagery', id, age, sex, group, language};
%         answer = inputdlg(prompt, 'VisualImagery', 2, defaults);
%         [studyTitle, id, age, sex, group, language] = deal(answer{:}); % all input variables are strings
    case 'experiment'
        ok = [];
        while ~strcmp(ok,'y')
            id = input('Subject ID:  ', 's');
            session = input('Session:  ', 's');
            age = input('Age:  ','s');
            sex = input('Sex:  ','s');
            group = input('Group:  ','s');
            language = input('Language: DE/EN.  ','s'); language = upper(language);
            ok = input('\nContinue? Y/N.  ','s'); ok = lower(ok);
        end
       
%         defaults = {'VisualImagery', '', '', '', '', ''};
%         [studyTitle, id, age, sex, group, language] = deal(defaults{:});
%         while isempty(id) || isempty(age) || isempty(sex) || isempty(group) || isempty(language)
%             % Set participant info for output file using input prompt
%             prompt = {'TitleOfStudy', 'Subject ID', 'Age', 'Sex', 'Group', 'Language'};
%             defaults = {'VisualImagery', id, age, sex, group, language};
%             answer = inputdlg(prompt, 'VisualImagery', 2, defaults);
%             [studyTitle, id, age, sex, group, language] = deal(answer{:}); % all input variables are strings
%             if ~strcmp(language,'EN') && ~strcmp(language,'DE')
%                 fprintf(['Language code not valid:\n',...
%                     'Use ''DE'' for german or ''EN'' for english.\n']);
%             end
%         end
end

logPath = fullfile(mainPath,['sub_' id],'log');
if exist(logPath,'dir') == 0
    mkdir(logPath)
end

outFile = fullfile(logPath,['sub_' id '_log_s' session '_' datestr(now,'yymmddHHMM')]);

% Check to avoid overiding an existing file
if exist([outFile,'.mat']) == 2 || exist([outFile,'.xls']) == 2
    fileproblem = input('Output files already exist! OVERWRITE (1/DEFAULT), or break (2)?');
    if fileproblem == 2
        return;
    elseif isempty(fileproblem) | fileproblem == 1
        delete([outFile, '.mat']);
        delete([outFile, '.xls']);
    end
end 

% Check for available temp file to resume session
tempFile = dir(fullfile(logPath,['sub_' id '_log_s' session '_*_temp.mat']));
if ~isempty(tempFile)
    if numel(tempFile) > 1
        error('More than 1 temporary log file present. Sort out your mess, then try again.');
        return;
    else
%         answer = questdlg('CAUTION: Temp file exists. Resume session or start new?', 'Temp file exists', 'Resume','New','Cancel','Cancel');
        answer = input('CAUTION: Temp file exists. Resume (R) session or start new (N)? R/N  ','s');
        answer = lower(answer);
        switch answer
            case {'resume', 'res', 'r'}
                tempLog = load(fullfile(logPath,tempFile.name));
                lastLog = load(tempLog.Experiment.Subject.out);
                % find last completed run
                lastRun = lastLog.Experiment.Log.currentRun;
                lastTrial = lastLog.Experiment.Log.currentTrial;
                if lastTrial == lastLog.Experiment.Design.Run(lastRun).nTrials
                    lastRun = lastRun+1;
                end    
                totalRuns = lastLog.Experiment.Design.nRuns;
                
                resumePromt = ['Completed runs: ' num2str(lastRun-1) ' of ' num2str(totalRuns) ' - resume from run (default = ' num2str(lastRun) '):  '];
%                 nextRun = inputdlg(resumePromt, 'Resume', 1, {num2str(lastRun)});
%                 nextRun = str2num(nextRun{1});
                nextRun = input(resumePromt);
                if isempty(nextRun), nextRun = lastRun; end
                
                Experiment.Mode.Resume.file = lastLog.Experiment.Subject.out;
                Experiment.Mode.Resume.run = nextRun;
            case {'new','n'}
                warning('Start new session with new log file.');
            otherwise
                error('Unexpected input');
                return;
        end
    end
end 

% run training?
% Experiment.Mode.training = questdlg('Run training?', 'Run training', 'Yes','No','No');
train = input('Run training? Y/N.  ', 's');
train = lower(train);
switch train
    case{'yes','y'}
        Experiment.Mode.training = 'Yes';
    case{'no','n'}
        Experiment.Mode.training = 'No';
    otherwise
        error('Unexpected input');
        return;
end

Subject = struct();
Subject.id = id;
Subject.session = session;
Subject.age = age;
Subject.sex = sex;
Subject.group = group;
Subject.language = language;
Subject.path = logPath;
Subject.out = outFile;

Experiment.Subject = Subject;