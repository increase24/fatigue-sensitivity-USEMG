function feature=TDAR6_RMS(data,lenofWindow,step)
lenofData=length(data);
feature=zeros(floor(lenofData/step),11);
for i=0:step:lenofData-step %i代表滑窗的中点
    if(i-lenofWindow/2+1<=0) 
        exactData=data(1:i+lenofWindow/2);
    elseif(i+lenofWindow/2>lenofData)
        exactData=data(i-lenofWindow/2+1:lenofData);
    else
        exactData=data(i-lenofWindow/2+1:i+lenofWindow/2);
    end
    feature1=Get_single_window_feature(exactData,1);
    feature2=Get_single_window_feature(exactData,3);
    feature3=Get_single_window_feature(exactData,7);
    feature(i/step+1,:)=[feature1 feature2 feature3]';
end
end