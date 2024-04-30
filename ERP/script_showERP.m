obj=showERP()
obj.Data=cat(3, FB11_case_pre_data);

obj.Data= showERP.applyLowPassFilter(FB11_case_pre_data,250, 10)

% obj.Data=cat(3, FB21_case_pre_data, FB21_control_data);
samplingRate = 250;
timeRangeAnalysisMS = [0, 800];
timeRangeOrignalMS = [-1000, 2000];
chansIdx= CA;
obj=prepareAveragedData(obj, chansIdx, samplingRate, timeRangeAnalysisMS, timeRangeOrignalMS);
figure('Color', [1 1 1]); % Create a new figure with white background
plot_ERPs(obj, [115, 215, 255] / 255, 'test','',[0,800],0, 'SE')
plot_subERPs(obj,chansIdx, 'test', 'test', [0,600], 0)


figure
subplot(3,2,1)
plot_topo(obj,samplingRate,[200,250], timeRangeOrignalMS, chanlocs,'')
subplot(3,2,2)
plot_topo(obj,samplingRate,[250,300], timeRangeOrignalMS, chanlocs,'')
subplot(3,2,3)
plot_topo(obj,samplingRate,[300,350], timeRangeOrignalMS, chanlocs,'')
subplot(3,2,4)
plot_topo(obj,samplingRate,[350,400], timeRangeOrignalMS, chanlocs,'')
subplot(3,2,5)
plot_topo(obj,samplingRate,[400,450], timeRangeOrignalMS, chanlocs,'')
subplot(3,2,6)
plot_topo(obj,samplingRate,[500,550], timeRangeOrignalMS, chanlocs,'')
