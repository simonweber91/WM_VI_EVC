function save_log(Experiment)

% Save Log Files
% Input: Struct 'Experiment' with fields 'Subject'
% Output:   (1) .mat file with table 'Log' (concatenated tables from
%               Subject.Log) and stuct 'Experiment' (Stimulus data is
%               removed before saving to reduce file size)
%           (2) .xls file with table 'Log'

Subject = Experiment.Subject;
nRuns = Experiment.Design.nRuns;

% Concatenate Log tables
for iRun = 1:nRuns
    if iRun == 1
        Log = Experiment.Log.Run(iRun).table;
    else
        Log = [Log;Experiment.Log.Run(iRun).table];
    end
end

% Write log files
if exist('Log','var')
    save([Subject.out,'.mat'],'Experiment','Log');
%    writetable(Log,[Subject.out,'.xls']);
end
