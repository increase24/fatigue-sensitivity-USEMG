function feature=TD(data)
lenofWindow=255;
lenofData=length(data);
feature=zeros(lenofData,4);
for i=1:lenofData
    if(i<128) 
        exactData=data(1:i+(lenofWindow-1)/2);
    elseif i>(lenofData+1-(lenofWindow+1)/2)
        exactData=data(i-(lenofWindow-1)/2:lenofData);
    else
        exactData=data(i-(lenofWindow-1)/2:i+(lenofWindow-1)/2);
    end
    feature1=Get_single_window_feature(exactData,1);
    feature(i,:)=feature1';
end
end