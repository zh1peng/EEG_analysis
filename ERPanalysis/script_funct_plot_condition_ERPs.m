 load('/media/NAS/EEGdata/Methadone_eMID/pooled_data/pooled_erp_16Hz_8trials.mat')
% Define the color schemes

colorPre = [142, 122, 181]./255; 
colorPost = [228, 147, 179]./255; 
colorControl = [128, 188, 189]./255; 
% Define channel groups with their respective channels
channelGroups = {
    struct('name', 'FL', 'channels', [12, 18, 19, 22, 23, 23, 26, 27]),
    struct('name', 'FR', 'channels', [2, 3, 4, 5, 9, 10, 123, 124]),
    struct('name', 'FM', 'channels', [15, 16]),
    struct('name', 'FA', 'channels', [12, 18, 19, 22, 23, 23, 26, 27, 2, 3, 4, 5, 9, 10, 123, 124, 15, 16]),
    struct('name', 'CL', 'channels', [24, 25, 26, 28, 29, 30, 20, 13, 7]),
    struct('name', 'CR', 'channels', [103, 104, 105, 106, 110, 111, 112, 116, 117, 118]),
    struct('name', 'CM', 'channels', [6, 119]),
    struct('name', 'CA', 'channels', [24, 25, 26, 28, 29, 30, 20, 13, 7, 103, 104, 105, 106, 110, 111, 112, 116, 117, 118, 6, 119]),
    struct('name', 'PL', 'channels', [52, 53, 54, 61, 51, 47, 42, 37, 31]),
    struct('name', 'PR', 'channels', [78, 79, 80, 86, 87, 92, 93, 97, 98]),
    struct('name', 'PC', 'channels', [55, 62]),
    struct('name', 'PA', 'channels', [52, 53, 54, 61, 51, 47, 42, 37, 31, 78, 79, 80, 86, 87, 92, 93, 97, 98, 55, 62]),
    struct('name', 'OL', 'channels', [64, 65, 66, 67, 58, 59, 60]),
    struct('name', 'OR', 'channels', [76, 77, 83, 84, 85, 90, 91, 95, 96]),
    struct('name', 'OM', 'channels', [72, 75]),
    struct('name', 'OA', 'channels', [64, 65, 66, 67, 58, 59, 60, 76, 77, 83, 84, 85, 90, 91, 95, 96, 72, 75])
};



% Define the conditions and their associated data and attributes
conditions = {
    struct('name', 'Win Cue', 'preData', C101_case_pre_data, 'postData', C101_case_post_data, 'controlData', C101_control_data),
    struct('name', 'Loss Cue', 'preData', C102_case_pre_data, 'postData', C102_case_post_data, 'controlData', C102_control_data),
    struct('name', 'Neut Cue', 'preData', C103_case_pre_data, 'postData', C103_case_post_data, 'controlData', C103_control_data),
    struct('name', 'Win Hit', 'preData', FB11_case_pre_data, 'postData', FB11_case_post_data, 'controlData', FB11_control_data),
    struct('name', 'Win Miss', 'preData', FB10_case_pre_data, 'postData', FB10_case_post_data, 'controlData', FB10_control_data),
    struct('name', 'Loss Hit', 'preData', FB21_case_pre_data, 'postData', FB21_case_post_data, 'controlData', FB21_control_data),
    struct('name', 'Loss Miss', 'preData', FB20_case_pre_data, 'postData', FB20_case_post_data, 'controlData', FB20_control_data),
    struct('name', 'Neut Hit', 'preData', FB31_case_pre_data, 'postData', FB31_case_post_data, 'controlData', FB31_control_data),
    struct('name', 'Neut Miss', 'preData', FB30_case_pre_data, 'postData', FB30_case_post_data, 'controlData', FB30_control_data)
};

% Define the channel index, sampling rate, and time ranges

samplingRate = 250;
timeRangeAnalysisMS = [0, 1000];
timeRangeOrignalMS = [-1000, 2000];


for cGroup = 1:length(channelGroups)
   chanGroupName = channelGroups{cGroup}.name;
    chansIdx = channelGroups{cGroup}.channels;
% Loop through each condition and plot ERPs
for i = 1:length(conditions)
    condition = conditions{i};
    figureTitle = sprintf('%s - %s', condition.name, chanGroupName)
    func_plot_condition_ERPs(figureTitle, condition.preData, condition.postData, condition.controlData, chansIdx, samplingRate, timeRangeAnalysisMS, timeRangeOrignalMS, colorPre, colorPost, colorControl);
    
    % Save the figure with the condition name
    saveas(gcf, fullfile('/media/NAS/EEGdata/Methadone_eMID/ERP_plots_16Hz_8trials',[sprintf('%s_%s', condition.name, chanGroupName) '.png']));
    close all
end
end