function normTFdata = func_BL_norm(TFdata, baselineRange, samplingRate, timeOffsetMs, normType)
% func_BL_norm performs baseline correction of time-frequency data.
%
% This function normalizes time-frequency data (TFdata) by various methods
% relative to a baseline period. The baseline is defined by the baselineRange
% input and is used to compute the mean power across the specified time
% interval. The normalized data can be expressed in dB change from the mean
% baseline power, raw subtraction, z-score, or percentage change.
%
% Inputs:
%   TFdata        - A 4D matrix containing time-frequency data. The dimensions
%                   should be channels x time x freq x trials. 
%
%   baselineRange - A 2-element vector specifying the start and end times (in ms)
%                   of the baseline period. This period is used to calculate the
%                   mean baseline power for normalization.
%
%   samplingRate  - A scalar value indicating the sampling rate of the data in Hz.
%
%   timeOffsetMs  - A scalar specifying the time (in ms) relative to which the
%                   baselineRange is defined. This is often the time of an event
%                   of interest (e.g., stimulus onset).
%
%   normType      - A string specifying the type of normalization to perform.
%                   It can be one of the following: 'decibel', 'subtraction',
%                   'z-score', 'percentage'. Default is 'decibel'.
%
% Outputs:
%   normTFdata    - The normalized time-frequency data.
%
% Author: Zhipeng Cao
% Modified by: OpenAI's ChatGPT
% Date: 2024/03/05

    % Validate inputs
    if nargin < 5
        normType = 'decibel'; % default normalization type
    end
    
    validNormTypes = {'decibel', 'subtraction', 'z-score', 'percentage'};
    if ~ismember(normType, validNormTypes)
        error('Invalid normType. Must be one of: ''decibel'', ''subtraction'', ''z-score'', ''percentage''.');
    end
    
    % Other input validations here...
    
    % Calculate baseline indices
    baselineStartIdx = round(((baselineRange(1) - timeOffsetMs) / 1000) * samplingRate) + 1;
    baselineEndIdx = round(((baselineRange(2) - timeOffsetMs) / 1000) * samplingRate) + 1;

    % Extract baseline data
    baselineData = TFdata(:, baselineStartIdx:baselineEndIdx, :,:);
    meanBaseline = mean(baselineData, 2);
    stdBaseline = std(baselineData, 0, 2);

    % Check if meanBaseline contains zeros to avoid division by zero in certain cases
    if any(meanBaseline == 0, 'all')
        error('Mean baseline power is zero for one or more data points, which may lead to division by zero.');
    end

    % Perform normalization based on normType
    switch normType
        case 'decibel'
            normTFdata = 10 * log10(bsxfun(@rdivide, TFdata, meanBaseline));
            
        case 'subtraction'
            normTFdata = bsxfun(@minus, TFdata, meanBaseline);
            
        case 'z-score'
            normTFdata = bsxfun(@rdivide, bsxfun(@minus, TFdata, meanBaseline), stdBaseline);
            
        case 'percentage'
            normTFdata = bsxfun(@rdivide, bsxfun(@minus, TFdata, meanBaseline), meanBaseline) * 100;
            
        otherwise
            error('Unexpected normalization type.');
    end
end