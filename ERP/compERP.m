classdef compERP
    properties
        g1Data % chan*point*sub
        g2Data % chan*point*sub
        g1ChanAvg % point*sub in  timeRangeAnalysisMS
        g2ChanAvg % point*sub in
        statResults % store stat results
    end
    methods
        
        function obj = prepareAveragedData(obj, chansIdx, samplingRate, timeRangeAnalysisMS, timeRangeOrignalMS, applyFilter)
    % Validate input arguments
    if nargin < 5
        error('All input arguments except applyFilter (chansIdx, samplingRate, timeRangeAnalysisMS, timeRangeOrignalMS) must be provided.');
    end
    
    if isempty(chansIdx) || isempty(samplingRate) || isempty(timeRangeAnalysisMS) || isempty(timeRangeOrignalMS)
        error('Input arguments cannot be empty.');
    end
    
    if ~isnumeric(samplingRate) || ~isnumeric(timeRangeAnalysisMS) || ~isnumeric(timeRangeOrignalMS)
        error('samplingRate, timeRangeAnalysisMS, and timeRangeOrignalMS must be numeric.');
    end
    
    if ~isvector(timeRangeAnalysisMS) || numel(timeRangeAnalysisMS) ~= 2
        error('timeRangeAnalysisMS must be a vector of two elements.');
    end
    
    if ~isvector(timeRangeOrignalMS) || numel(timeRangeOrignalMS) ~= 2
        error('timeRangeOrignalMS must be a vector of two elements.');
    end
    
    % Validate that necessary data properties are present
    if isempty(obj.g1Data) || isempty(obj.g2Data)
        error('g1Data and g2Data must not be empty.');
    end
    
    obj.g1Data=double(obj.g1Data);
    obj.g2Data=double(obj.g2Data);
    
    
    % Set default for applyFilter if not provided
    if nargin < 6
        applyFilter = false;
    end
    
    % Apply low-pass filter if requested
    if applyFilter
        obj.g1Data = compERP.applyLowPassFilter(obj.g1Data, samplingRate, 16); % Apply filter to g1Data
        obj.g2Data = compERP.applyLowPassFilter(obj.g2Data, samplingRate, 16); % Apply filter to g2Data
    end

    % Calculate the timepoint indices for timeRangeAnalysisMS
    startTimeIdx = round((timeRangeAnalysisMS(1) - timeRangeOrignalMS(1)) * samplingRate / 1000) + 1;
    endTimeIdx = round((timeRangeAnalysisMS(2) - timeRangeOrignalMS(1)) * samplingRate / 1000) + 1;
    
    % Validate the calculated indices
    if startTimeIdx < 1 || endTimeIdx > size(obj.g1Data, 2) || startTimeIdx > endTimeIdx
        error('timeRangeAnalysisMS is out of the bounds of the provided data or incorrectly specified.');
    end
    
    % Validate channel indices
    if any(chansIdx > size(obj.g1Data, 1)) || any(chansIdx < 1)
        error('chansIdx contains indices out of the bounds of available channels.');
    end
    
    % Select the data within timeRangeAnalysisMS and only for the channels in chansIdx
    selectedG1Data = obj.g1Data(chansIdx, startTimeIdx:endTimeIdx, :);
    selectedG2Data = obj.g2Data(chansIdx, startTimeIdx:endTimeIdx, :);
    
    % Average the selected data across the channels
    obj.g1ChanAvg = squeeze(mean(selectedG1Data, 1));
    obj.g2ChanAvg = squeeze(mean(selectedG2Data, 1));
end
        
        
        function obj = compareGroups(obj, comparisonType, subID)
            % Validate required data
            if isempty(obj.g1ChanAvg) || isempty(obj.g2ChanAvg)
                error('Averaged data (g1ChanAvg and g2ChanAvg) must not be empty.');
            end
            
            % Check for the comparison type and perform the appropriate analysis
            switch comparisonType
                case 'ttest2'
                    % Perform a standard t-test for each time point
                    for time_i = 1:size(obj.g1ChanAvg, 1)
                        [h, p, ci, stats] = ttest2(obj.g1ChanAvg(time_i, :), obj.g2ChanAvg(time_i, :));
                        obj.statResults(time_i).tValue = stats.tstat;
                        obj.statResults(time_i).pValue = p;
                        obj.statResults(time_i).ci = ci;
                        obj.statResults(time_i).effectSize = compERP.computeEffectSize(stats); % call static function
                    end
                    
                case 'lme'
                    % Validate subID for LME
                    if nargin < 3 || isempty(subID)
                        error('subID is required for longitudinal comparison.');
                    end
                    if length(subID) ~= size(obj.g1ChanAvg, 2)+size(obj.g2ChanAvg, 2)
                        error('Length of subID must match the number of subjects in g1ChanAvg.');
                    end
                    % Loop through each time point
                    for time_i = 1:size(obj.g1ChanAvg, 1)
                        % Prepare response data for current time point
                        responseVar = [obj.g1ChanAvg(time_i, :)'; obj.g2ChanAvg(time_i, :)'];
                        
                        % Group variable indicating g1ChanAvg or g2ChanAvg
                        groupVar = [repmat({'G1'}, size(obj.g1ChanAvg, 2), 1); repmat({'G2'}, size(obj.g2ChanAvg, 2), 1)];
                        
                        % Subject IDs
                        subIDVar = subID;
                        
                        % Create table for LME
                        tbl = table(responseVar, groupVar, subIDVar, 'VariableNames', {'Response', 'Group', 'Subject'});
                        tbl.Group = categorical(tbl.Group);
                        tbl.Subject = categorical(tbl.Subject);
                        tbl.Response =double(tbl.Response);
                        % Fit LME model with subject as a random effect and Group as fixed effect
                        lmeModel = fitlme(tbl, 'Response ~ Group + (1|Subject)');
                        coeffs = lmeModel.Coefficients;
                        % Store fixed effects estimates
                        % Store the fixed effects estimates and associated statistics
                        obj.statResults(time_i).Estimate = coeffs.Estimate(2);
                        obj.statResults(time_i).SE = coeffs.SE(2);
                        obj.statResults(time_i).DF = coeffs.DF(2);
                        obj.statResults(time_i).tValue = coeffs.tStat(2);
                        obj.statResults(time_i).pValue = coeffs.pValue(2);
                        obj.statResults(time_i).ci = [coeffs.Lower(2), coeffs.Upper(2)];
                    end   
                otherwise
                    error('Unsupported comparison type. Choose ''ttest2'' or ''lme''.');
            end
        end
        
      function plot_ERPs(obj, col1, col2, legend1, legend2,  title2show, timeRangePlot, hide_x, shadingType)
    % Calculate group averages
    g1GroupAvg = mean(obj.g1ChanAvg, 2);  % Already averaged across channels, time point x subj
    g2GroupAvg = mean(obj.g2ChanAvg, 2);
    
    % Generate x-axis values based on time range and number of points
    x = linspace(timeRangePlot(1), timeRangePlot(2), length(g1GroupAvg));
   
    % Start plotting
    hold on;
    
    % Plot ERP lines for each group
    plot(x, g1GroupAvg, 'Color', col1, 'LineWidth', 3);  % Group 1
    plot(x, g2GroupAvg, 'Color', col2, 'LineWidth', 3);  % Group 2

    % Determine and plot shading if specified
    if strcmp(shadingType, 'STD') || strcmp(shadingType, 'SE')
        % Compute shading values based on shadingType
        if strcmp(shadingType, 'STD')
            g1Shading = std(obj.g1ChanAvg, 0, 2);  % Standard deviation across subjects
            g2Shading = std(obj.g2ChanAvg, 0, 2);
        elseif strcmp(shadingType, 'SE')
            g1Shading = std(obj.g1ChanAvg, 0, 2) / sqrt(size(obj.g1ChanAvg, 2));  % Standard error
            g2Shading = std(obj.g2ChanAvg, 0, 2) / sqrt(size(obj.g2ChanAvg, 2));
        end
        
        % Fill area for shading
        fill([x fliplr(x)], [g1GroupAvg - g1Shading; flipud(g1GroupAvg + g1Shading)], col1, 'FaceAlpha', 0.3, 'EdgeColor', 'none');
        fill([x fliplr(x)], [g2GroupAvg - g2Shading; flipud(g2GroupAvg + g2Shading)], col2, 'FaceAlpha', 0.3, 'EdgeColor', 'none');
    end

    % Plot zero line for reference
    refline([0 0]);

    % Set plot properties
    xlabel('Time (ms)');
    ylabel('{\it¦Ì}Volt'); 
    set(gca, 'YDir', 'reverse', 'FontSize', 14, 'FontName', 'Arial');
    
    % Hide x-axis ticks and labels if specified
    if hide_x
        set(gca, 'XTick', [], 'XColor', [1 1 1]);
    end
    
    % Add legend and title
    legend(legend1, legend2, 'FontSize', 14, 'FontName', 'Arial', 'Location', 'Southwest');
    if ~isempty(title2show)
        title(title2show, 'FontSize', 14, 'FontName', 'Arial');
    end
    
    hold off;
end

function []=plot_subERPs(obj, legend1, legend2, title2show, timeRangePlot, hide_x)
    % Generate x-axis values based on the time range and number of time points
    x = linspace(timeRangePlot(1), timeRangePlot(2), size(obj.g1ChanAvg, 1));

    % Plot ERPs for Group 1
    figure; % Open a new figure for Group 1
    hold on;
    % Apply a color map for subjects of Group 1
    colors = lines(size(obj.g1ChanAvg, 2));
    for subi = 1:size(obj.g1ChanAvg, 2)
        subERP = squeeze(obj.g1ChanAvg(:, subi));
        plot(x, subERP, 'Color', colors(subi, :));  % Unique color for each subject
    end
    compERP.finalizePlot(legend1, title2show, hide_x);

    % Plot ERPs for Group 2 in a new figure
    figure; % Open a new figure for Group 2
    hold on;
    % Apply a color map for subjects of Group 2
    colors = lines(size(obj.g2ChanAvg, 2));
    for subi = 1:size(obj.g2ChanAvg, 2)
        subERP = squeeze(obj.g2ChanAvg(:, subi));
        plot(x, subERP, 'Color', colors(subi, :));  % Unique color for each subject
    end
    compERP.finalizePlot(legend2, title2show, hide_x);
end
    end
    
    methods(Static)
        function effectSize = computeEffectSize(stats)
            % Static implementation that doesn't use obj properties
            effectSize = stats.tstat / sqrt(stats.df + 1);
        end
        
        function finalizePlot(legendText, titleText, hideXAxis)
    % Plot zero line for reference
    hline = refline([0 0]);
    set(hline, 'Color', 'k', 'LineWidth', 1);

    % Set plot properties
    xlabel('Time (ms)');
    ylabel('{\it¦Ì}Volt');
    set(gca, 'YDir', 'reverse', 'FontSize', 14, 'FontName', 'Arial');
    
    % Hide x-axis ticks and labels if specified
    if hideXAxis
        set(gca, 'XTick', [], 'XColor', [1 1 1]);
        xlabel([]);
    end
    
    % Add legend and title if provided
    if ~isempty(legendText)
        legend(legendText, 'FontSize', 14, 'FontName', 'Arial', 'Location', 'Southwest');
    end
    if ~isempty(titleText)
        title(titleText, 'FontSize', 14, 'FontName', 'Arial');
    end
    
    hold off;
        end
        
function filteredData = applyLowPassFilter(data, Fs, fc)
    % Design the Butterworth filter
    N = 2;  % Filter order
    Wn = fc / (Fs / 2);  % Normalized cutoff frequency
    [b, a] = butter(N, Wn, 'low');  % Filter coefficients
    
    % Initialize filteredData
    filteredData = data;
    
    % Apply the filter to the data for each subject and channel
    for chan = 1:size(data, 1)
        for subj = 1:size(data, 3)
            filteredData(chan, :, subj) = filtfilt(b, a, data(chan, :, subj));
        end
    end
end
        
    end
end
