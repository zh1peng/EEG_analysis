function EEG=processICA(EEG, icaRun, logFile, logPath)
    icaLabel = sprintf('ICA%d', icaRun); % Construct ICA label (e.g., ICA1, ICA2)
    logPrint(logFile, ['Running ' icaLabel '...']);
    if size(EEG.data,3)>1
        tmpdata = reshape( EEG.data, [EEG.nbchan, EEG.pnts*EEG.trials]);
        tmprank = getrank(tmpdata);
    else
        tmprank=getrank(EEG.data)
    end
    filterEEG = pop_eegfiltnew(EEG, 'locutoff', 1, 'plotfreqz', 0);
    filterEEG = pop_runica(filterEEG, 'icatype', 'runica', 'extended', 1, 'interrupt', 'off', 'pca', tmprank-icaRun+1); % minus 1 to make sure ica runs get different resutls
    EEG.icaweights = filterEEG.icaweights;
    EEG.icasphere = filterEEG.icasphere;
    EEG.icachansind = filterEEG.icachansind;
    EEG.icawinv=filterEEG.icawinv;
    EEG.icaact=[];
    EEG.icaact = eeg_getica(EEG);
    EEG = eeg_checkset(EEG);

    logPrint(logFile, [icaLabel ' - Identifying bad ICs...']);
    EEG = pop_iclabel(EEG, 'default');
    EEG = pop_icflag(EEG, [NaN NaN; 0.7 1; 0.7 1; 0.7 1; 0.7 1; 0.7 1; NaN NaN]);
    BadIC_IClabel = find(EEG.reject.gcompreject == 1)';

%     % Find the index for channel 'E126'
idx1 = find(strcmp({EEG.chanlocs.labels}, 'E26'));
% Find the index for channel 'E129'
idx2 = find(strcmp({EEG.chanlocs.labels}, 'E128'));
%     % Find the index for channel 'E126'
idx3 = find(strcmp({EEG.chanlocs.labels}, 'E8'));
% Find the index for channel 'E129'
idx4 = find(strcmp({EEG.chanlocs.labels}, 'E125'));
eyeChan=[idx1, idx2, idx3, idx4];

ICA_list = component_properties(EEG, eyeChan);
BadIC_FASTER = find(min_z25(ICA_list) == 1)';

BadIC_FASTER_filtered = [];
if ~isempty(BadIC_FASTER)
for i = 1:length(BadIC_FASTER)
    icIdx = BadIC_FASTER(i); % Current bad IC index
    if EEG.etc.ic_classification.ICLabel.classifications(icIdx,1) <= 0.7
        % If brain prob <= 0.7, consider it a bad IC and add to the list
      BadIC_FASTER_filtered = [BadIC_FASTER_filtered, icIdx];
     pop_prop(EEG, 0, icIdx, NaN, {'freqrange',[2 40] });
    % Save the figure. Note: Figures will be saved in the specified logPath
    batch_saveas(gcf, fullfile(logPath, [icaLabel, '_BadICs_FASTER_', num2str(icIdx) '_Properties.png']));
    end
end
end


if ~isempty(BadIC_IClabel)
for i = 1:length(BadIC_IClabel)
    icIdx = BadIC_IClabel(i); % Current bad IC index
    pop_prop(EEG, 0, icIdx, NaN, {'freqrange',[2 40] });
    % Save the figure. Note: Figures will be saved in the specified logPath
    batch_saveas(gcf, fullfile(logPath, [icaLabel, '_BadICs_IClabel_' num2str(icIdx) '_Properties.png']));

end
end

BadIC_all = unique([BadIC_IClabel, BadIC_FASTER_filtered]);
% Assuming draw_selectcomps is a custom function or part of your workflow
EEG.reject.gcompreject(BadIC_all)=1;
draw_selectcomps(EEG, [1:35]); 
batch_saveas(gcf, fullfile(logPath, [icaLabel '_reject_p1.png']));
% Try-catch block to handle different component numbers
try
    draw_selectcomps(EEG, [36:70]);
    batch_saveas(gcf, fullfile(logPath, [icaLabel '_reject_p2.png']));
catch
    draw_selectcomps(EEG, [36:size(EEG.icaweights,1)]);
    batch_saveas(gcf, fullfile(logPath, [icaLabel '_reject_p2.png']));
end

    EEG = pop_subcomp(EEG, BadIC_all, 0);
    EEG = eeg_checkset(EEG);

    % Log bad ICs identified by each method and total
logPrint(logFile, sprintf('%s rank: %s', icaLabel,num2str(tmprank)));
logPrint(logFile, sprintf('%s Bad ICs Identified by ICLabel: %d\nDetails: %s', icaLabel, length(BadIC_IClabel), mat2str(BadIC_IClabel)));
logPrint(logFile, sprintf('%s Bad ICs Identified by FASTER: %d\nDetails: %s', icaLabel, length(BadIC_FASTER), mat2str(BadIC_FASTER)));
logPrint(logFile, sprintf('%s Bad ICs Identified by FASTER (exclude IClabel Brain): %d\nDetails: %s', icaLabel, length(BadIC_FASTER_filtered), mat2str(BadIC_FASTER_filtered)));
logPrint(logFile, sprintf('%s Total Unique Bad ICs: %d\nDetails: %s\n', icaLabel, length(BadIC_all), mat2str(BadIC_all)));
end
