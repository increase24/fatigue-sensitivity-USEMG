% clear
% clc

function Feature=extract(data_path,trial_num,motion_num,holdtime_per_action,resttime_per_action,headtime,tailtime,resttime_per_trial)
tic %tic和toc是用来记录matlab命令执行的时间
%ExFeature需要使用这些全局变量
global sampling_freq sample_length channel_num sample_depth sound_speed zero_delay frame_rate
%% Experiment & Data processing parameters
channel_num = 4;
real_begin_time = 0;%second
totaltime_per_action = holdtime_per_action + resttime_per_action;
coretime_per_action = holdtime_per_action - headtime - tailtime; %second  每个动作的实际有效数据时间
totaltime_per_trial = totaltime_per_action * motion_num + resttime_per_trial;
win_length = 20; %特征提取窗长
start_channel =1;
end_channel =4;

%% Ultrasound device parameters
sample_dots = 1000;
sample_length = sample_dots; % num of dots sampled
sample_depth = 38.5e-3;
sample_depth = repmat(sample_depth, 1, channel_num);
sampling_freq = 20e6;
sampling_freq = repmat(sampling_freq, 1, channel_num);
zero_delay = 0e-6; 
sound_speed = 1540; % m/s
frame_rate = 10;


%% other Parameters
feature_num = frame_rate* coretime_per_action * motion_num * trial_num; %实际上是样本数
frame_num = frame_rate  * holdtime_per_action * motion_num * trial_num;
foobar_raw = zeros(channel_num, sample_length);
fea_len = length(ExFeature(foobar_raw, win_length)); %特征长度
Feature(feature_num, fea_len) = 0;

%% data read
foobar_raw = load (data_path);  %超声信号原始数据
% foobar_raw = foobar_raw.myfoobar;
raw_frame_num = NaN;
raw_data = cell(1, channel_num); % videonum x channel_num
% raw_force = cell(1, 1);

if isnan(raw_frame_num) 
    raw_frame_num = floor(length(foobar_raw(:,1))/sample_dots);% first run in first loop
else                                                 
    if raw_frame_num ~= floor(length(foobar_raw(:,1))/sample_dots) % not first loop
        error 'line numbers not compatible.';
    end
end
display(['line number is ' num2str(raw_frame_num)]);
data_frame_num = raw_frame_num - real_begin_time * frame_rate;
foobar_raw = foobar_raw(1 + real_begin_time * frame_rate * sample_dots : raw_frame_num * sample_dots,start_channel:end_channel);
% data_frame_num = floor(length(foobar_raw(:,1))/sample_dots);

for ch_no = 1:channel_num  
    raw_data{1,ch_no} = reshape(foobar_raw(:,ch_no), sample_dots, data_frame_num)';
end

warning 'Remeber to check the length of each matrix!'
disp 'loading finishes '

raw_data_combine = cell(data_frame_num ,1);
disp 'start combining '
temp = zeros(channel_num, sample_dots);
for i = 1: data_frame_num
    for j = 1: channel_num
        temp(j,:) = raw_data{1, j}(i, :);
    end
    raw_data_combine{i, 1} = temp;
end
disp 'combine ending '


%%  Extraction of Feature
m =1;
for i = 1 : trial_num
     for j = 1 : motion_num
         for k = ((i-1)* totaltime_per_trial + (j-1)*totaltime_per_action + headtime )*frame_rate + 1  : ((i-1)*totaltime_per_trial + (j-1)*totaltime_per_action + headtime + coretime_per_action ) * frame_rate
               Feature(m, :) = ExFeature(raw_data_combine{k,1}, win_length);
               m = m +1;     
         end
     end
end


toc;
end
