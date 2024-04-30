FL=[12,18,19,22,23,23,26,27];
FR=[2,3,4,5,9,10,123,124];
FM=[15,16];
FA=[FL,FR,FM];
CL=[24,25,26,28,29,30,20,13,7];
CR=[103,104,105,106,110,111,112,116,117,118];
CM=[6,119];
CA=[CL,CR,CM];
PL=[52,53,54,61,51,47,42,37,31];
PR=[78,79,80,86,87,92,93,97,98];
PC=[55,62];
PA=[PL,PR,PC];
OL=[64,65,66,67,58,59,60];
OR=[76,77,83,84,85,90,91,95,96];
OM=[72, 75];
OA=[OL,OR,OM];

load('V:\Methadone_eMID\pooled_data\better_pooled_erp.mat')

C101_obj=compERP();
C101_obj.g1Data=C102_case_pre_data;
C101_obj.g2Data=C102_control_data;
C101_obj=prepareAveragedData(C101_obj, FA, 250, [0,1000], [-1000, 2000])
% C101_obj=compareGroups(C101_obj, 'ttest2')
% C101_obj=compareGroups(C101_obj,  'lme', [C101_case_pre_subs; C101_case_post_subs])
figure
plot_ERPs(C101_obj,[255 51 0]./255,[255 153 102]./255,'Pre','Control', 'Win Cue', [0,1000],0, 'SE')
% plot_subERPs(C101_obj,'Post','Control', 'Win Cue', [0,1000],0)



C101_obj=compERP();
C101_obj.g1Data=C102_case_post_data;
C101_obj.g2Data=C102_control_data;
C101_obj=prepareAveragedData(C101_obj, FA, 250, [0,1000], [-1000, 2000])
% C101_obj=compareGroups(C101_obj, 'ttest2')
% C101_obj=compareGroups(C101_obj,  'lme', [C101_case_pre_subs; C101_case_post_subs])
figure
plot_ERPs(C101_obj,[255 51 0]./255,[255 153 102]./255,'Post','Control', 'Win Cue', [0,1000],0, 'SE')
% plot_subERPs(C101_obj,'Post','Control', 'Win Cue', [0,1000],0)

C101_obj=compERP();
C101_obj.g1Data=C102_case_pre_data;
C101_obj.g2Data=C102_case_post_data;
C101_obj=prepareAveragedData(C101_obj, FA, 250, [0,1000], [-1000, 2000])
% C101_obj=compareGroups(C101_obj, 'ttest2')
% C101_obj=compareGroups(C101_obj,  'lme', [C101_case_pre_subs; C101_case_post_subs])
figure
plot_ERPs(C101_obj,[255 51 0]./255,[255 153 102]./255,'Pre','Post', 'Win Cue', [0,1000],0, 'SE')