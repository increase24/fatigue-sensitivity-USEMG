clc
clear
subject = "S1";
path_allData=dir(char("../dataset/"+subject+"/AUS/*.txt"));
for index=1:length(path_allData) % loop for all ultrasound data files
    path_data=path_allData(index).name;
    path_folder=path_allData(index).folder;
    path_US=string(path_allData(index).folder)+"/"+string(path_allData(index).name); 
%%   exactUSFeature Parameter:
%     path_US; 
%     trial_num;trial
%     motion_num:
%     holdtime_per_action:
%     resttime_per_action:
%     headtime:
%     tailtime:
%     resttime_per_trial:
    USFeature=extractUSFeature(path_US,1,33,10,0,0,0,0);
    %save emgFeature as csv
    save_name="Feature_"+path_data;
    mkdir('../featureset'); 
    mkdir('../featureset/',char(subject));
    mkdir(char("../featureset/"+ subject + "/"),'AUS');
    csvwrite(char("../featureset/"+subject+"/AUS/"+save_name),USFeature)
end
