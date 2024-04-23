function generateHTML(folderPath)
    % Ensure the natsort function is available
    if ~exist('natsort', 'file')
        error('natsort function is required. Please install from MATLAB File Exchange.');
    end
    
    % Check if the folder exists
    if ~exist(folderPath, 'dir')
        error('The specified folder does not exist.');
    end
    
    % Patterns for PNG files
   patterns = {
        'BadChannel_Faster', 'Bad Channel - FASTER';
        'BadChannel_Kurt', 'Bad Channel - Kurtosis';
        'BadChannel_Spec', 'Bad Channel - Spectrum';
        'ICA1_reject', 'ICA1 - Reject Plots';
        'ICA1_BadICs_FASTER', 'ICA1 - Bad ICs FASTER';
        'ICA1_BadICs_IClabel', 'ICA1 - Bad ICs ICLabel';
        'ICA2_reject', 'ICA2 - Reject Plots';
        'ICA2_BadICs_FASTER', 'ICA2 - Bad ICs FASTER';
        'ICA2_BadICs_IClabel', 'ICA2 - Bad ICs ICLabel';
        'ICA3_reject', 'ICA3 - Reject Plots';
        'ICA3_BadICs_FASTER', 'ICA3 - Bad ICs FASTER';
        'ICA3_BadICs_IClabel', 'ICA3 - Bad ICs ICLabel';
    };

    % Initialize HTML content with styles for reject plots and regular plots
    htmlContent = ['<html><head><title>EEG Preprocessing Results</title><style>' ...
                   'body { font-family: Arial, sans-serif; margin: 20px; }' ...
                   '.image { width: 100%; max-width: 400px; height: auto; margin: 10px 0; }' ...
                   '.rejectPlot { width: 100%; max-width: 800px; height: auto; margin: 10px 0; }' ...
                   '.container { margin-bottom: 40px; }' ...
                   'h2 { color: #333; }</style></head><body><h1>EEG Preprocessing Results</h1>'];

       % Search for files and append to HTML content
    for i = 1:size(patterns, 1)
        pattern = patterns{i, 1};
        heading = patterns{i, 2};
        files = dir(fullfile(folderPath, [pattern, '*.png']));
        fileNames = {files.name};
        sortedFileNames = natsort(fileNames); % Sort file names numerically
        
        if ~isempty(files)
            htmlContent = [htmlContent, '<div class="container"><h2>', heading, '</h2>'];
            for fileName = sortedFileNames
                fullImgPath = fullfile(folderPath, fileName{1});
                % Anchor tag to make image clickable and viewable in full size
                htmlContent = [htmlContent, ...
                    '<a href="', fileName{1}, '" target="_blank">', ...
                    '<img class="image" src="', fileName{1}, '" alt="', fileName{1}, '">', ...
                    '</a>'];
            end
            htmlContent = [htmlContent, '</div>'];
        end
    end

    % Close HTML content
    htmlContent = [htmlContent, '</body></html>'];

    % Write HTML file
    htmlFilePath = fullfile(folderPath, 'PreprocessingRecords.html');
    fileId = fopen(htmlFilePath, 'w');
    fprintf(fileId, '%s', htmlContent);
    fclose(fileId);

    disp(['HTML file created at ', htmlFilePath]);
end
