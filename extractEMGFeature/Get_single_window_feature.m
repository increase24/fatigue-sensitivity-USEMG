 %% 提取每个窗数据的特征
function feature_single_window=Get_single_window_feature(data,type)
[~,channel]=size(data);
delta=0.000004;
switch type
    case 1   %TD
        MAV = zeros(1,channel);
        ZC  = zeros(1,channel);
        SSC = zeros(1,channel);
        WL  = zeros(1,channel);
        for i=1:channel
            MAV(i) = mean(abs(data(:,i)));
            ZC(i) = 0;
            SSC(i) = 0;
            WL(i) = 0;
            for j = 1:length(data(:,i))-1
                if ((data(j,i) > 0 && data(j+1,i) < 0) || (data(j,i) < 0 && data(j+1,i) > 0)) && (abs(data(j,i)-data(j+1,i)) >= delta)
                    ZC(i) = ZC(i)+1;
                end
                WL(i) = WL(i) + abs(data(j+1,i)-data(j,i));
            end
            
            for k = 2:length(data(:,i))-1
                if ((data(k,i) > data(k-1,i) && data(k,i) > data(k+1,i)) || (data(k,i) < data(k-1,i) && data(k,i) < data(k+1,i))) && (abs(data(k,i)-data(k-1,i)) >= delta || abs(data(k,i)-data(k+1,i)) >= delta)
                    SSC(i) = SSC(i)+1;
                end
            end
        end
        feature_single_window=[MAV ZC SSC WL];
    case 2   %AR4
        ar_order=4;
        arcoff = zeros(ar_order,channel);
        for i=1:channel
            temp = arburg(data(:,i),ar_order);
            arcoff(:,i) = temp(2:end);
            %[~,arcoff(:,i)] = arfit(data(:,i),ar_order,ar_order);
        end
        arcoef = reshape(arcoff,ar_order*channel,1);
        feature_single_window = arcoef';
    case 3   %AR6
        ar_order=6;
        arcoff = zeros(ar_order,channel);
        for i=1:channel
            temp = arburg(data(:,i),ar_order);
            arcoff(:,i) = temp(2:end);
            %[~,arcoff(:,i)] = arfit(data(:,i),ar_order,ar_order);
        end
        arcoef = reshape(arcoff,ar_order*channel,1);
        feature_single_window = arcoef';
    case 4   %TDAR4
        MAV = zeros(1,channel);
        ZC  = zeros(1,channel);
        SSC = zeros(1,channel);
        WL  = zeros(1,channel);
        for i=1:channel
            MAV(i) = mean(abs(data(:,i)));
            ZC(i) = 0;
            SSC(i) = 0;
            WL(i) = 0;
            for j = 1:length(data(:,i))-1
                if ((data(j,i) > 0 && data(j+1,i) < 0) || (data(j,i) < 0 && data(j+1,i) > 0)) && (abs(data(j,i)-data(j+1,i)) >= delta)
                    ZC(i) = ZC(i)+1;
                end
                WL(i) = WL(i) + abs(data(j+1,i)-data(j,i));
            end
            
            for k = 2:length(data(:,i))-1
                if ((data(k,i) > data(k-1,i) && data(k,i) > data(k+1,i)) || (data(k,i) < data(k-1,i) && data(k,i) < data(k+1,i))) && (abs(data(k,i)-data(k-1,i)) >= delta || abs(data(k,i)-data(k+1,i)) >= delta)
                    SSC(i) = SSC(i)+1;
                end
            end
        end
        ar_order=4;
        arcoff = zeros(ar_order,channel);
        for i=1:channel
            temp = arburg(data(:,i),ar_order);
            arcoff(:,i) = temp(2:end);
            %[~,arcoff(:,i)] = arfit(data(:,i),ar_order,ar_order);
        end
        arcoef = reshape(arcoff,ar_order*channel,1);
        feature_single_window=[MAV ZC SSC WL arcoef'];
    case 5    %TDAR6
        MAV = zeros(1,channel);
        ZC  = zeros(1,channel);
        SSC = zeros(1,channel);
        WL  = zeros(1,channel);
        for i=1:channel
            MAV(i) = mean(abs(data(:,i)));
            ZC(i) = 0;
            SSC(i) = 0;
            WL(i) = 0;
            for j = 1:length(data(:,i))-1
                if ((data(j,i) > 0 && data(j+1,i) < 0) || (data(j,i) < 0 && data(j+1,i) > 0)) && (abs(data(j,i)-data(j+1,i)) >= delta)
                    ZC(i) = ZC(i)+1;
                end
                WL(i) = WL(i) + abs(data(j+1,i)-data(j,i));
            end
            
            for k = 2:length(data(:,i))-1
                if ((data(k,i) > data(k-1,i) && data(k,i) > data(k+1,i)) || (data(k,i) < data(k-1,i) && data(k,i) < data(k+1,i))) && (abs(data(k,i)-data(k-1,i)) >= delta || abs(data(k,i)-data(k+1,i)) >= delta)
                    SSC(i) = SSC(i)+1;
                end
            end
        end
        ar_order=6;
        arcoff = zeros(ar_order,channel);
        for i=1:channel
            temp = arburg(data(:,i),ar_order);
            arcoff(:,i) = temp(2:end);
            %[~,arcoff(:,i)] = arfit(data(:,i),ar_order,ar_order);
        end
        arcoef = reshape(arcoff,ar_order*channel,1);
        feature_single_window=[MAV ZC SSC WL arcoef'];
    case 6
        MAV = zeros(1,channel);
        MAX  = zeros(1,channel);
        for i=1:channel
            MAV(i)=mean(abs(data(:,i)));
            MAX(i)=max(data(:,i));
        end
        feature_single_window=[MAV MAX];
    case 7
        RMS = zeros(1,channel);
        for i=1:channel
            RMS(i)=rms(data(:,i));
        end
        feature_single_window=RMS;
%     case 8 %中值频率
%         MF=
    otherwise
end
end