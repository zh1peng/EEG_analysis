% Define the directory where your .set files are stored
% Get a list of all qced_*.set files in the directory
searchPath='/media/NAS/EEGdata/Methadone_eMID/qced_eegdata'
filepattern = '^qced_xh.*set';
[filepath,filename]=filesearch_regexp(searchPath, filepattern,0)
setFiles=fullfile(searchPath, filename);

% Define the markers you're interested in
markers = {'C101', 'C102', 'C103', 'FB10', 'FB11', 'FB20', 'FB21', 'FB30', 'FB31'};


subid={}
eMID_data=[];
badsub={};
% Loop through each .set file
for i = 1:length(setFiles)
    % Construct the full file path
    setFile =setFiles{i};
    
    % Load the dataset
    OrigEEG = pop_loadset(setFile);
    OrigEEG=eeg_checkset(OrigEEG);
    % Extract the subject and session info from the filename
   [startIndex, endIndex] = regexp(setFile, 'xh[hc]*\d+_s\d+');
    subjectSession = setFile(startIndex:endIndex);
    subid=[subid; subjectSession];
    % Loop through each marker
    for m = 1:length(markers)
        marker = markers{m};
         try
        tmpEEG = pop_epoch(OrigEEG, {marker }, [-1  2]);
        tmpEEG=eeg_checkset(tmpEEG);
        tmpEEG= pop_eegfiltnew(tmpEEG, 'hicutoff',16);
        tmpEEG=eeg_checkset(tmpEEG);
%         tmpEEG = pop_rmbase(tmpEEG, [-500 0] ,[]);
%         tmpEEG=eeg_checkset(tmpEEG);
          eval(['eMID_data.',subjectSession,'.', marker, '=tmpEEG.data;']);
         catch
             badinfo=[subjectSession, '_', marker];
            badsub=[badinfo; badsub];
       eval(['eMID_data.',subjectSession,'.', marker, '=[];']);
        end
    end
end




%% add group information to subid
groupInfo = cell(size(subid));
extractedSubid = cell(size(subid));

% Loop through each subid
for i = 1:length(subid)
    subid_i = subid{i};
    
    % Determine group based on subid pattern

  
    if contains(subid_i, 'hc')
        groupInfo{i} = 'control';
    elseif contains(subid_i, '_s1')
        groupInfo{i} = 'case_pre';
    elseif contains(subid_i, '_s2')
        groupInfo{i} = 'case_post';
    end
    
    % Extract the subid (without session info)
    tokens = regexp(subid_i, '(xh[\w]*)(?:_s\d+)', 'tokens');
    if ~isempty(tokens)
        extractedSubid{i} = tokens{1}{1};
    end
end

% Combine original subid, groupInfo, and extractedSubid into one cell array
subid = [subid, extractedSubid,groupInfo];

times=OrigEEG.times;
chanlocs=OrigEEG.chanlocs;
%% Save the all_data structure to a .mat file
save('/media/NAS/EEGdata/Methadone_eMID/pooled_data/eMID_data_16Hz.mat', 'eMID_data','markers','subid','badsub', '-v7.3');
save('/media/NAS/EEGdata/Methadone_eMID/pooled_data/info.mat', 'times','chanlocs');