data_path='/media/NAS/EEGdata/Methadone_eMID/prep_eegdata10'
[path,name]=filesearch_regexp(data_path, '.set')
for n = 1: length(name)
    filename=fullfile(path{n},name{n})
    EEG=pop_loadset('filename',name{n},'filepath',path{n})
    quality_index=data_quality(EEG)
    results{n,1}=name{n};
    results{n,2}=quality_index;
end
foldernames=cellfun(@(x) x(1:end-17),results(:,1),'Unif',0)
foldernames(:,2)=results(:,2)
T=cell2table(results);
writetable(T, '/media/NAS/EEGdata/Methadone_eMID/prep_eegdata10/qc_score.csv')
