load('/media/NAS/EEGdata/Methadone_eMID/pooled_data/better_eMID_data.mat')
% Get unique group names
groupNames = unique(subid(:,3));
for groupName_i = 1:length(groupNames)
    % Extract the group name to find
    groupNameToFind = groupNames{groupName_i};  % Ensure to use cell indexing
    
    % Find the rows where the third column matches the group name
    matchingRows = strcmp(subid(:,3), groupNameToFind);
    
    % Extract the sublist names that match the specified group name
    sublist = subid(matchingRows, 1);
    
    % Call your function with the extracted sublists for the current group
    func_extract_groups_tfd(eMID_data,markers,  [1:0.5:40], [-200, 0], 250, -1000, groupNameToFind, sublist);
end

% remove variables
clearvars eMID_data groupName_i groupNames  groupNameToFind  markers  matchingRows  subid sublist
save('/media/NAS/EEGdata/Methadone_eMID/pooled_data/nsf_tfd_8trials.mat')

