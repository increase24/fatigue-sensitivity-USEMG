function [line,vFeature] = Ex_processedSignal_Feature( data, win_length )
% UNTITLED3 Summary of this function goes here
% Output is a line vector whose every 3 componenets stand for an ROI.
% Input is voltage amplitude in a same frame, one channel each line .
% based on \B test\2_April\feature_j.m

% parameters definition
global sampling_freq sample_length channel_num sample_depth sound_speed zero_delay

% channel_num = 1;
sample_dots = 1000;
sample_length = sample_dots; % num of dots sampled
sample_depth = 38.5e-3;
sample_depth = repmat(sample_depth, 1, channel_num);
sampling_freq = 20e6;
sampling_freq = repmat(sampling_freq, 1, channel_num);
zero_delay = 0e-6; 
sound_speed = 1540; % m/s

range = win_length;
burst_tone_freq = 5e6; % !!IMPORTANT!! used in tgc coefficient calc and Gaussian filter mid-freq
start = 20; % start of x
endo = 20; % end of x, avoid gaussian filter jitter
tgc_alpha = 0.05; % [dB/(MHz cm)]   
sampling_balance = 128; % median of sampling range  %选用128更好
filter_bandwidth = 110; % in percentage 
log_comp_ratio = 0.4;

% Declaration and error handling
mDepth = zeros(channel_num, sample_length);
for i = 1 : channel_num % channel_no
    mDepth(i, :) = (1 : sample_length) / sample_length * sample_depth(i); % mDepth contains depth value for each dot, each line for a ch
    mDepth(i, :) = sound_speed * zero_delay + mDepth(i, :);
    tgc(i, :) = exp(tgc_alpha * burst_tone_freq / 1e6 * mDepth(i, :) * 100);
%     foobar_t(i) = 1 : sample_length(i);

end

% d = fdesign.bandpass('N,F3dB1,F3dB2', 6, 2e6, 6e6, sampling_freq); 
% Hd = design(d,'butter');

vFeature = [];
fit_foobar = 1 : range; %for fit only

% if start < range 
%     error('x_start must be greater than radius');
% end
if sample_length ~= size(data, 2)
    error('sample length mismatched.')
end

%%  process start


for i = 2 % channel_no
    line = bsxfun(@times, tgc(i, :), data(i, :) - sampling_balance); % wow, how should you know
    line = gaussianFilter(line, sampling_freq(i), burst_tone_freq, filter_bandwidth); 
    line = envelopeDetection(line);
%     line = smooth(line, 10)'; % smooth
    line = logCompression(line, log_comp_ratio);
%     line = line;
    
% { 
%normal code part
for tail = start + range - 1 : range : (sample_length - endo)
    xcor = (tail - range + 1) : tail;% x coordinates in a typical segment
    %线性拟合提参数
    %foobar = polyfit(fit_foobar, line(xcor), 1); %一维线性拟合:k-b特征
    %foobar = polyfit(fit_foobar, line(xcor), 3); %效果有些差
    foobar = [mean(line(xcor)) var(line(xcor))];
    %AR模型提参数
    %m = ar(line(xcor),4,'ls');
    %m = ar(line(xcor),6);
    %foobar = m.A;
    vFeature = [vFeature foobar]; % IMPORTANT!!!! 
%     clear foobar
end
% }

end
