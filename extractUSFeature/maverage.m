function [ ave ] = maverage( recognition )
%��ƽ��ʶ����
    [r,~] = size(recognition);
    %sum = 0;
    for i = 1 : r
        ave(i) = recognition(i, i) / sum(recognition(i, :));
    end
    ave(i + 1) = sum(ave(1 : r)) / r;
    ave = ave';
end