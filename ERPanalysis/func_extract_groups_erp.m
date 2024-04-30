function [] = func_extract_groups_erp(eMID_data, conditions, baselineRange, samplingRate, timeOffsetMs, sublistName, sublist)
    % eMID_data: The structured data containing all subjects and conditions
    % conditions: Cell array of conditions to process (e.g., {'C101', 'C102', 'C103'})
    % baselineRange: Two-element vector specifying the baseline period in milliseconds (e.g., [-200, 0])
    % samplingRate: Sampling rate of the data (e.g., 250 Hz)
    % timeOffsetMs: Time offset in milliseconds from the onset of the stimuli to the start of the data window (e.g., -1000 for -1s)
    % sublistName: Name of the sublist to be used as a prefix for output variables (e.g., 'g1')
    % sublist: Cell array of subject IDs to be included in the analysis (e.g., {'sub1', 'sub2'})

    % Convert time offset from milliseconds to seconds


    % Calculate baseline indices, taking into account the time offset
    baselineStartIdx = round(((baselineRange(1) - timeOffsetMs) / 1000) * samplingRate) + 1;
    baselineEndIdx = round(((baselineRange(2) - timeOffsetMs) / 1000) * samplingRate) + 1;
    
    % Process each condition
    for condition = conditions
        condition = condition{1}; % Extract string from cell
        subAverage = [];
        allTrialCounts = [];
        subinfo={};
        % Process each subject in the sublist
        for subject_i =1: length(sublist)
            subject = sublist{ subject_i }; % Extract string from cell
            if isfield(eMID_data, subject) && isfield(eMID_data.(subject), condition)
                data = eMID_data.(subject).(condition);

                % Check for valid trials
                if ~isempty(data) && size(data, 3) >= 8
                    % Remove baseline
                    baseline = mean(data(:, baselineStartIdx:baselineEndIdx, :), 2);
                    baselineReplicated = repmat(baseline, [1, size(data, 2), 1]);
                    data = data - baselineReplicated;

                    % Average across trials
                    avgData = mean(data, 3);

                    % Append to subAverage
                    subAverage = cat(3, subAverage, avgData);
                    
                    % record sub
                    subinfo=[subinfo; regexprep(subject, '_s\d+$', '')];
                    
                end

                % Record trial count
                trialCount = size(data, 3);
                allTrialCounts = [allTrialCounts; {subject, trialCount}];
            end
        end

        % Create variable names with the sublist prefix
        varName_data = sprintf('%s_%s_data',  condition, sublistName);
        varName_trialN = sprintf('%s_%s_trialN', condition, sublistName);
        varName_subinfo=sprintf('%s_%s_subs', condition, sublistName);
        
        % Convert the cell array of trial counts to a table
        trialCountsTable = cell2table(allTrialCounts, 'VariableNames', {'SubjectID', 'TrialCount'});

        % Assign the table and data to variables in the base workspace with the dynamically created names
        assignin('base', varName_trialN, trialCountsTable);
        assignin('base', varName_data, subAverage);
        assignin('base', varName_subinfo, subinfo);
    end
end
