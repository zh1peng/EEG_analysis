function preprocess_eMID6(inputMFF, outputPath)
% inputMFF= '/media/NAS/EEGdata/Methadone_eMID/eegdata/xh01_s1_mid.mff';
% outputPath='/media/NAS/EEGdata/Methadone_eMID/prep_eegdata5';
% preprocessEEG Function to preprocess EEG data
% Usage: preprocessEEG('path/to/input/file.mff', 'path/to/output/directory')
% Ensure EEGLAB and FASTER paths are added before calling this function

% Extract the base name for the output file and log file
[~, baseName, ~] = fileparts(inputMFF);
outputFile = fullfile(outputPath, [baseName '_preprocessed.set']);
logPath=fullfile(outputPath, [baseName,'_log']);

if ~exist(logPath, 'dir')
    % If the folder does not exist, create it
    mkdir(logPath)
end

logFile = fullfile(logPath, [baseName '_preprocessed.log']);

% Start EEGlab
eeglab nogui;

logPrint(logFile, '=== Starting EEG Preprocessing ===');

%% Import data
logPrint(logFile, 'Importing data...');
EEG = pop_mffimport({inputMFF}, {'code'}, 0, 0);
EEG = eeg_checkset(EEG);

%% Down Sampling
logPrint(logFile, 'Downsampling...');
EEG = pop_resample(EEG, 250);
EEG = eeg_checkset(EEG);

%% Remove data before first 'bgin' event
logPrint(logFile, 'Removing data before first ''bgin'' event...');
allEvent = {EEG.event.type}';
bginIdx = find(strcmp(allEvent, 'bgin'));
bginLatency = ([EEG.event(bginIdx(1)).latency]' / EEG.srate) - 1;
EEG = pop_select(EEG, 'notime', [0 bginLatency]);
EEG = eeg_checkset(EEG);

%% Filter
logPrint(logFile, 'Applying filters...');
EEG = pop_eegfiltnew(EEG, 'locutoff', 47, 'hicutoff', 53, 'revfilt', 1, 'plotfreqz', 0);
EEG = pop_eegfiltnew(EEG, 'locutoff', 0.1, 'plotfreqz', 0);
EEG = pop_eegfiltnew(EEG, 'hicutoff', 40, 'plotfreqz', 0);
EEG = eeg_checkset(EEG);

%% Find and remove bad channels from the data

logPrint(logFile, 'Identifying bad channels...');
RefChan = 129; % Original reference channel
Exclude= [26,128,8,125] % Exclude Eye Channels
Chan2check=setdiff([1:129], [Exclude, RefChan])

% Bad channels identified by kurtosis
[~, BadChan_Kurt] = pop_rejchan(EEG, 'elec', Chan2check, 'threshold', [-5 5], 'norm', 'on', 'measure', 'kurt');

% Bad channels identified by spectrum criteria
[~, BadChan_Spec] = pop_rejchan(EEG, 'elec', Chan2check, 'threshold', [-5 5], 'norm', 'on', 'measure', 'spec', 'freqrange', [0.1 40]);

% Bad channels identified using FASTER
channel_list = channel_properties(EEG, [1:129], RefChan);
BadChan_FASTER_idx = find(min_z(channel_list) == 1)';
BadChan_FASTER_idx = setdiff(BadChan_FASTER_idx, Exclude); % Exclude Eye Channels
BadChan_all = unique([RefChan, BadChan_FASTER_idx, BadChan_Spec, BadChan_Kurt]);

if ~isempty(BadChan_FASTER_idx)
    for i = 1:length(BadChan_FASTER_idx)
        chanIdx = BadChan_FASTER_idx(i);
        if chanIdx ~= RefChan
            % Use pop_prop to plot channel properties. Note: You might need to adjust the parameters based on your EEG structure and needs
            pop_prop(EEG, 1, chanIdx, NaN, {'freqrange',[2 40] });
            % Save the figure. Note: Figures will be saved in the specified logPath
            batch_saveas(gcf, fullfile(logPath, ['BadChannel_Faster_' num2str(chanIdx) '_Properties.png']));
        end
    end
end

if ~isempty(BadChan_Spec)
    for i = 1:length(BadChan_Spec)

        chanIdx = BadChan_Spec(i);
        if chanIdx ~= RefChan
            % Use pop_prop to plot channel properties. Note: You might need to adjust the parameters based on your EEG structure and needs
            pop_prop(EEG, 1, chanIdx, NaN, {'freqrange',[2 40] });
            % Save the figure. Note: Figures will be saved in the specified logPath
            batch_saveas(gcf, fullfile(logPath, ['BadChannel_Spec_' num2str(chanIdx) '_Properties.png']));
        end
    end
end

if ~isempty(BadChan_Kurt)
    for i = 1:length(BadChan_Kurt)
        chanIdx = BadChan_Kurt(i);
        if chanIdx ~= RefChan
            % Use pop_prop to plot channel properties. Note: You might need to adjust the parameters based on your EEG structure and needs
            pop_prop(EEG, 1, chanIdx, NaN, {'freqrange',[2 40] });
            % Save the figure. Note: Figures will be saved in the specified logPath
            batch_saveas(gcf, fullfile(logPath, ['BadChannel_Kurt_' num2str(chanIdx) '_Properties.png']));
        end
    end
end

% Log bad channels identified by each method and total
logPrint(logFile, sprintf('Bad Channels Identified by Kurtosis: %d\nDetails: %s', length(BadChan_Kurt), mat2str(BadChan_Kurt)));
logPrint(logFile, sprintf('Bad Channels Identified by Spectrum: %d\nDetails: %s', length(BadChan_Spec), mat2str(BadChan_Spec)));
logPrint(logFile, sprintf('Bad Channels Identified by FASTER: %d\nDetails: %s', length(BadChan_FASTER_idx), mat2str(BadChan_FASTER_idx)));
logPrint(logFile, sprintf('Total Unique Bad Channels: %d\nDetails: %s\n', length(BadChan_all), mat2str(BadChan_all)));

%% remove bad channels
ORIGchanlocs=EEG.chanlocs;
EEG = pop_select( EEG, 'rmchannel',BadChan_all);

%% interp bad channels
% EEG=pop_interp(EEG, BadChan_all, 'spherical');

%% Reference to the average
logPrint(logFile, 'Re-referencing to average...');
EEG = pop_reref( EEG, []); % exclude eye chans
EEG = eeg_checkset(EEG);
%% Epoch data
logPrint(logFile, 'Epoching data...');
EEG = pop_epoch(EEG, {'C101', 'C102', 'C103', 'FB10', 'FB11', 'FB20', 'FB21', 'FB30', 'FB31'}, [-1 2]);
EEG = eeg_checkset(EEG);

%% Find bad epochs
logPrint(logFile, 'Identifying bad epochs...');
[~, BadEpoch_autorej] = pop_autorej(EEG, 'nogui', 'on', 'maxrej', 2);
epoch_list = epoch_properties(EEG, [1:EEG.nbchan]);
BadEpoch_FASTER = find(min_z(epoch_list) == 1)';
BadEpoch_all = unique([BadEpoch_autorej, BadEpoch_FASTER]);

% Log bad epochs identified by each method and total
logPrint(logFile, sprintf('Bad Epochs Identified by Auto Reject: %d\nDetails: %s', length(BadEpoch_autorej), mat2str(BadEpoch_autorej)));
logPrint(logFile, sprintf('Bad Epochs Identified by FASTER: %d\nDetails: %s', length(BadEpoch_FASTER), mat2str(BadEpoch_FASTER)));
logPrint(logFile, sprintf('Total Unique Bad Epochs: %d\nDetails: %s\n', length(BadEpoch_all), mat2str(BadEpoch_all)));


if ~isempty(BadEpoch_all)
    %EEG = pop_rejepoch(EEG, BadEpoch_all, 0);
    EEG = pop_select( EEG, 'notrial', BadEpoch_all);
    EEG = eeg_checkset(EEG);
end

%% Run ICA and find bad ICs
EEG=processICA(EEG, 1, logFile, logPath); % For ICA1
EEG=processICA(EEG, 2, logFile, logPath); % For ICA2

%% Find bad epochs
logPrint(logFile, 'Identifying bad epochs...');
[~, BadEpoch_autorej] = pop_autorej(EEG, 'nogui', 'on', 'maxrej', 2);
epoch_list = epoch_properties(EEG, [1:EEG.nbchan]);
BadEpoch_FASTER = find(min_z(epoch_list) == 1)';
BadEpoch_all = unique([BadEpoch_autorej, BadEpoch_FASTER]);

% Log bad epochs identified by each method and total
logPrint(logFile, sprintf('Bad Epochs Identified by Auto Reject: %d\nDetails: %s', length(BadEpoch_autorej), mat2str(BadEpoch_autorej)));
logPrint(logFile, sprintf('Bad Epochs Identified by FASTER: %d\nDetails: %s', length(BadEpoch_FASTER), mat2str(BadEpoch_FASTER)));
logPrint(logFile, sprintf('Total Unique Bad Epochs: %d\nDetails: %s\n', length(BadEpoch_all), mat2str(BadEpoch_all)));


if ~isempty(BadEpoch_all)
    %EEG = pop_rejepoch(EEG, BadEpoch_all, 0);
    EEG = pop_select( EEG, 'notrial', BadEpoch_all);
    EEG = eeg_checkset(EEG);
end
%% Find bad channels per epoch
logPrint(logFile, 'Identifying bad channels per epoch...');
bad_chan_cell = [];
for epoch_i = 1:size(EEG.data, 3)
    bad_chan_epoch_list = single_epoch_channel_properties(EEG, epoch_i, [1:EEG.nbchan]);
    tmp_bad = find(min_z(bad_chan_epoch_list) == 1);
    bad_chan_cell{epoch_i} = tmp_bad;
    logPrint(logFile, sprintf('Epoch %d - Bad Channels: %d, Details: %s', epoch_i, length(tmp_bad), mat2str(tmp_bad)));
end
EEG = h_epoch_interp_spl(EEG, bad_chan_cell);

%% interp removed chan
EEG=pop_interp(EEG, ORIGchanlocs, 'spherical');
EEG = eeg_checkset(EEG);

%% redo ICA for QC purpose
if size(EEG.data,3)>1
    tmpdata = reshape( EEG.data, [EEG.nbchan, EEG.pnts*EEG.trials]);
    tmprank = getrank(tmpdata);
else
    tmprank=getrank(EEG.data);
end
EEG= pop_runica(EEG, 'icatype', 'runica', 'extended', 1, 'interrupt', 'off', 'pca', tmprank-length(BadChan_all));
EEG = eeg_checkset(EEG);
%% Save dataset
logPrint(logFile, ['Saving preprocessed data to ' outputFile]);
EEG = pop_saveset(EEG, 'filename', outputFile);
generateHTML(logPath);
logPrint(logFile, '=== EEG Preprocessing Complete ===');

end
