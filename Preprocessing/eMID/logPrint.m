function logPrint(logFile, msg)
    % Open log file in append mode
    logFID = fopen(logFile, 'a');
    if logFID == -1
        error('Failed to open log file.');
    end
    
    % Function to log and print progress
    fprintf(logFID, '%s\n', msg); % Log message to file
    fprintf('%s\n', msg); % Also print message to MATLAB Command Window
    
    % Close the log file
    fclose(logFID);
end
