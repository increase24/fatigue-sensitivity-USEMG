clc
clear
subject = "S1";
path_allData=dir(char("../dataset/"+subject+"/sEMG/*.txt"));
for index=1:length(path_allData) % loop for all sEMG data files
    path_data=path_allData(index).name;
    path_folder=path_allData(index).folder;
    rawEMG=importdata(string(path_allData(index).folder)+"/"+string(path_allData(index).name)); 
    emgFeature=[TDAR6(rawEMG(:,1),250,100),TDAR6(rawEMG(:,2),250,100),TDAR6(rawEMG(:,3),250,100),TDAR6(rawEMG(:,4),250,100)];
    save_name="Feature_"+path_data;
    mkdir('../featureset'); 
    mkdir('../featureset/',char(subject));
    mkdir(char("../featureset/"+ subject + "/"),'sEMG');
    csvwrite(char("../featureset/"+subject+"/sEMG/"+save_name),emgFeature)
end



