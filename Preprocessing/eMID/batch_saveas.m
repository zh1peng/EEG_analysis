function batch_saveas(figHandle, saveName, scaleFactor)
    % Ensure figHandle is a valid figure handle
    if ~ishghandle(figHandle)
        error('Invalid figure handle provided.');
    end
    
    % Check if scaleFactor is provided, otherwise default to 1 (no scaling)
    if nargin < 3
        scaleFactor = 1.2;
    end
    
    % Get the current position of the figure
    currentPosition = get(figHandle, 'Position');
    
    % Scale the figure size by scaleFactor
    newPosition = currentPosition .* [1 1 scaleFactor scaleFactor];
    
    % Apply the new position to the figure
    set(figHandle, 'Position', newPosition);
    
    % Capture the figure after resizing
    frame = getframe(figHandle);  %GETFRAME can not capture figures with UI controls unless figure windows are displayed.
    img = frame2im(frame); % Convert the frame to an image matrix

    % Save the image
    imwrite(img, saveName); 
    % Save the figure using print 
    % print(figHandle, saveName, '-dpng', '-r300'); % '-r300' sets the
    % resolution to 300 dpi  Error message: Printing of uicontrols is not supported on this platform.
    
     % Save the figure using exportgraphics (requires MATLAB R2020a or newer)
    % exportgraphics(figHandle, saveName, 'Resolution', 300); % no label!
    % Optionally, you might want to reset the figure to its original size here
    % set(figHandle, 'Position', currentPosition);
    
    % Close the figure
    close(figHandle);
end



