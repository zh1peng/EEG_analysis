function preprocess_eMID(inputMFF, outputPath)
% preprocessEEG Function to preprocess EEG data
% Usage: preprocessEEG('path/to/input/file.mff', 'path/to/output/directory')
% Ensure EEGLAB and FASTER paths are added before calling this function

% Extract the base name for the output file and log file
[~, baseName, ~] = fileparts(inputMFF);
outputFile = fullfile(outputPath, [baseName '_preprocessed.set']);
logFile = fullfile(outputPath, [baseName '_preprocessed.log']);

% Open log file
logFID = fopen(logFile, 'w');

% Start EEGlab
eeglab nogui;

% Function to log and print progress
    function logPrint(msg)
        fprintf(logFID, '%s\n', msg); % Log message
        fprintf('%s\n', msg); % Print to screen
    end

logPrint('=== Starting EEG Preprocessing ===');

%% Import data
logPrint('Importing data...');
EEG = pop_mffimport({inputMFF}, {'code'}, 0, 0);
EEG = eeg_checkset(EEG);

%% Down Sampling
logPrint('Downsampling...');
EEG = pop_resample(EEG, 250);
EEG = eeg_checkset(EEG);

%% Remove data before first 'bgin' event
logPrint('Removing data before first ''bgin'' event...');
allEvent = {EEG.event.type}';
bginIdx = find(strcmp(allEvent, 'bgin'));
bginLatency = ([EEG.event(bginIdx(1)).latency]' / EEG.srate) - 1;
EEG = pop_select(EEG, 'notime', [0 bginLatency]);
EEG = eeg_checkset(EEG);

%% Filter
logPrint('Applying filters...');
EEG = pop_eegfiltnew(EEG, 'locutoff', 48, 'hicutoff', 52, 'revfilt', 1, 'plotfreqz', 0);
EEG = pop_eegfiltnew(EEG, 'locutoff', 0.1, 'plotfreqz', 0);
EEG = pop_eegfiltnew(EEG, 'hicutoff', 40, 'plotfreqz', 0);
EEG = eeg_checkset(EEG);

%% Find and remove bad channels from the data
logPrint('Identifying bad channels...');
RefChan = 129; % Original reference channel

% Bad channels identified by kurtosis
[~, BadChan_Kurt] = pop_rejchan(EEG, 'elec', [1:128], 'threshold', [-3 3], 'norm', 'on', 'measure', 'kurt');

% Bad channels identified by spectrum criteria
[~, BadChan_Spec] = pop_rejchan(EEG, 'elec', [1:128], 'threshold', [-3 3], 'norm', 'on', 'measure', 'spec', 'freqrange', [0.1 45]);

% Bad channels identified using FASTER
channel_list = channel_properties(EEG, [1:129], RefChan);
BadChan_FASTER_idx = find(min_z(channel_list) == 1)';
BadChan_all = unique([RefChan, BadChan_FASTER_idx, BadChan_Spec, BadChan_Kurt]);

% Log bad channels identified by each method and total
logPrint(sprintf('Bad Channels Identified by Kurtosis: %d\nDetails: %s', length(BadChan_Kurt), mat2str(BadChan_Kurt)));
logPrint(sprintf('Bad Channels Identified by Spectrum: %d\nDetails: %s', length(BadChan_Spec), mat2str(BadChan_Spec)));
logPrint(sprintf('Bad Channels Identified by FASTER: %d\nDetails: %s', length(BadChan_FASTER_idx), mat2str(BadChan_FASTER_idx)));
logPrint(sprintf('Total Unique Bad Channels: %d\nDetails: %s\n', length(BadChan_all), mat2str(BadChan_all)));


% Interpolating bad channels
if ~isempty(BadChan_all)
    for badi = 1:length(BadChan_all)
        EEG = pop_interp(EEG, BadChan_all(badi), 'spherical');
    end
end
interpChan_n = length(BadChan_all);
EEG = eeg_checkset(EEG);

%% Reference to the average
logPrint('Re-referencing to average...');
EEG = pop_reref(EEG, []);
EEG = eeg_checkset(EEG);

%% Epoch data
logPrint('Epoching data...');
EEG = pop_epoch(EEG, {'C101', 'C102', 'C103', 'FB10', 'FB11', 'FB20', 'FB21', 'FB30', 'FB31'}, [-1 2]);
EEG = eeg_checkset(EEG);

%% Find bad epochs
logPrint('Identifying bad epochs...');
[~, BadEpoch_autorej] = pop_autorej(EEG, 'nogui', 'on', 'maxrej', 2);
epoch_list = epoch_properties(EEG, [1:EEG.nbchan]);
BadEpoch_FASTER = find(min_z(epoch_list) == 1)';

BadEpoch_all = unique([BadEpoch_autorej, BadEpoch_FASTER]);

% Log bad epochs identified by each method and total
logPrint(sprintf('Bad Epochs Identified by Auto Reject: %d\nDetails: %s', length(BadEpoch_autorej), mat2str(BadEpoch_autorej)));
logPrint(sprintf('Bad Epochs Identified by FASTER: %d\nDetails: %s', length(BadEpoch_FASTER), mat2str(BadEpoch_FASTER)));
logPrint(sprintf('Total Unique Bad Epochs: %d\nDetails: %s\n', length(BadEpoch_all), mat2str(BadEpoch_all)));


if ~isempty(BadEpoch_all)
    EEG = pop_rejepoch(EEG, BadEpoch_all, 0);
    EEG = eeg_checkset(EEG);
end

%% Run ICA and find bad ICs
logPrint('Running ICA...');
filterEEG = pop_eegfiltnew(EEG, 'locutoff', 1, 'plotfreqz', 0);
filterEEG_ica = pop_runica(filterEEG, 'icatype', 'runica', 'extended', 1, 'interrupt', 'off', 'pca', EEG.nbchan - interpChan_n - 1);
EEG.icaweights = filterEEG_ica.icaweights;
EEG.icasphere = filterEEG_ica.icasphere;
EEG.icachansind = filterEEG_ica.icachansind;
EEG = eeg_checkset(EEG);

logPrint('Identifying bad ICs...');
EEG = pop_iclabel(EEG, 'default');
EEG = pop_icflag(EEG, [NaN NaN; 0.7 1; 0.7 1; 0.7 1; 0.7 1; 0.7 1; NaN NaN]);
BadIC_IClabel = find(EEG.reject.gcompreject == 1)';
ICA_list = component_properties(EEG, [126, 127]);
BadIC_FASTER = find(min_z25(ICA_list) == 1)';
BadIC_all = unique([BadIC_IClabel, BadIC_FASTER]);

% Log bad ICs identified by each method and total
logPrint(sprintf('Bad ICs Identified by ICLabel: %d\nDetails: %s', length(BadIC_IClabel), mat2str(BadIC_IClabel)));
logPrint(sprintf('Bad ICs Identified by FASTER: %d\nDetails: %s', length(BadIC_FASTER), mat2str(BadIC_FASTER)));
logPrint(sprintf('Total Unique Bad ICs: %d\nDetails: %s\n', length(BadIC_all), mat2str(BadIC_all)));

EEG = pop_subcomp(EEG, BadIC_all, 0);
EEG = eeg_checkset(EEG);

%% Find bad channels per epoch
logPrint('Identifying bad channels per epoch...');
bad_chan_cell = [];
for epoch_i = 1:size(EEG.data, 3)
    bad_chan_epoch_list = single_epoch_channel_properties(EEG, epoch_i, [1:EEG.nbchan]);
    tmp_bad = find(min_z(bad_chan_epoch_list) == 1);
    bad_chan_cell{epoch_i} = tmp_bad;
    
    logPrint(sprintf('Epoch %d - Bad Channels: %d, Details: %s', epoch_i, length(tmp_bad), mat2str(tmp_bad)));
end
EEG = h_epoch_interp_spl(EEG, bad_chan_cell);

%% Save dataset
logPrint(['Saving preprocessed data to ' outputFile]);
EEG = pop_saveset(EEG, 'filename', outputFile);

% Close log file
logPrint('=== EEG Preprocessing Complete ===');
fclose(logFID);
end
