function func_plot_condition_ERPs(conditionName, preData, postData, controlData, chansIdx, samplingRate, timeRangeAnalysisMS, timeRangeOrignalMS, colorPre, colorPost, colorControl)
    % Prepare the figure
     fig=figure;
      set(fig, 'Position', [100, 100, 1200, 1200]);  % [left, bottom, width, height]
    sgtitle([conditionName]); % Set the overall title for subplots

    % Create ERP objects for each comparison
    objPreControl = compERP();
    objPreControl.g1Data = preData;
    objPreControl.g2Data = controlData;
    objPreControl = prepareAveragedData(objPreControl, chansIdx, samplingRate, timeRangeAnalysisMS, timeRangeOrignalMS);

    objPostControl = compERP();
    objPostControl.g1Data = postData;
    objPostControl.g2Data = controlData;
    objPostControl = prepareAveragedData(objPostControl, chansIdx, samplingRate, timeRangeAnalysisMS, timeRangeOrignalMS);

    objPrePost = compERP();
    objPrePost.g1Data = preData;
    objPrePost.g2Data = postData;
    objPrePost = prepareAveragedData(objPrePost, chansIdx, samplingRate, timeRangeAnalysisMS, timeRangeOrignalMS);


    % Subplot 1: Pre vs. Control
    subplot(3, 1, 1);
    plot_ERPs(objPreControl, colorPre, colorControl, 'Pre', 'Control', '', [timeRangeAnalysisMS(1), timeRangeAnalysisMS(2)], 0, 'SE');
    title('Pre vs. Control');

    % Subplot 2: Post vs. Control
    subplot(3, 1, 2);
    plot_ERPs(objPostControl, colorPost, colorControl, 'Post', 'Control', '', [timeRangeAnalysisMS(1), timeRangeAnalysisMS(2)], 0, 'SE');
    title('Post vs. Control');

    % Subplot 3: Pre vs. Post
    subplot(3, 1, 3);
    plot_ERPs(objPrePost, colorPre, colorPost, 'Pre', 'Post', '', [timeRangeAnalysisMS(1), timeRangeAnalysisMS(2)], 0, 'SE');
    title('Pre vs. Post');
end