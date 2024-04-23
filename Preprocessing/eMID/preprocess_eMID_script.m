
clear;clc
addpath('/media/NAS/misc/matlab_toolbox/matlab_functions')
addpath('/media/NAS/misc/matlab_toolbox/eeglab2023.1')
addpath('/media/NAS/misc/matlab_toolbox/FASTER')

searchPath='/media/NAS/EEGdata/Methadone_eMID/eegdata'
filepattern = '.*mid.*';
[filepath,filename]=filesearch_regexp(searchPath, filepattern,0)
inputFiles=fullfile(searchPath, filename);
outputPath='/media/NAS/EEGdata/Methadone_eMID/prep_eegdata6'

if ~exist(outputPath, 'dir') % Check if the folder does not exist
    mkdir(outputPath); % Create the folder
    disp(['Folder "', outputPath, '" was created.']);
else
    disp(['Folder "', outputPath, '" already exists.']);
end



% Initialize parallel pool if not already started
if isempty(gcp('nocreate'))
    parpool(24); % Adjust the number of workers as needed
end


parfor i = 1:length(inputFiles)
    try
        % Call your preprocessing function
        preprocess_eMID6(inputFiles{i}, outputPath);
        
        % Optionally, log successful completion for each file
        fprintf('Successfully processed file: %s\n', inputFiles{i});
    catch ME
        % Log or handle the error for the current file
        fprintf('Error processing file: %s\n', inputFiles{i});
        fprintf('Error message: %s\n', ME.message);
        
        % Optionally, write the error information to a separate log file
        errorLogPath = fullfile(outputPath, sprintf('error_log_%d.txt', i)); % Unique error log for each iteration
        errorFID = fopen(errorLogPath, 'w');
        if errorFID ~= -1
            fprintf(errorFID, 'Error processing file: %s\n', inputFiles{i});
            fprintf(errorFID, 'Error message: %s\n', ME.message);
            fclose(errorFID);
        else
            fprintf('Failed to open error log file for file: %s\n', inputFiles{i});
        end
    end
end

 delete(gcp('nocreate'));  % Closes the current parallel pool