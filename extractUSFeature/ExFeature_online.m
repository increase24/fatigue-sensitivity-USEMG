function [ vFeature ] = ExFeature( data, win_length )
% the same ExFeature method as online code
%based on yuefeng offline code

% parameters definition
global sampling_freq sample_length chnum sample_depth sound_speed zero_delay

chnum = 4;
sample_length = 8*1024; % num of dots sampled
sample_depth = 63.1e-3;
sample_depth = repmat(sample_depth, 1, chnum);
sampling_freq = 100e6;
sampling_freq = repmat(sampling_freq, 1, chnum);
zero_delay = 0e-6; % lingwei yanchi in seconds
sound_speed = 1540; % m/s

range = win_length;
burst_tone_freq = 5e6;
start = 20; % start of x
endo = 20; % end of x, avoid gaussian filter jitter
tgc_alpha = 0.05; % [dB/(MHz cm)]   
sampling_balance = 128; % median of sampling range  %选用128更好
log_comp_ratio = 0.4;

% Declaration and error handling
mDepth = zeros(chnum, sample_length);
for i = 1 : chnum % channel_no
    mDepth(i, :) = (1 : sample_length) / sample_length * sample_depth(i); % mDepth contains depth value for each dot, each line for a ch
    mDepth(i, :) = sound_speed * zero_delay + mDepth(i, :);
    tgc(i, :) = exp(2*tgc_alpha * burst_tone_freq / 1e6 * mDepth(i, :) * 100);

end

vFeature = [];
fit_foobar = 1 : range; %for fit only

% if start < range 
%     error('x_start must be greater than radius');
% end
if sample_length ~= size(data, 2)
    error('sample length mismatched.')
end

%%  process start

n = 5;
for i = 1 : chnum % channel_no
    line = bsxfun(@times, tgc(i, :), data(i, :) - sampling_balance); % wow, how should you know
    %abs
    line = abs(line);
    for j = n: length(line)
        line(j) = sum(line( j - n +1 : j), 2)/n;
    end
    
    %line = gaussianFilter(line, sampling_freq(i), burst_tone_freq, filter_bandwidth); 
    %line = envelopeDetection(line);
    line = logCompression(line, log_comp_ratio);
% { 
%normal code part
for tail = start + range  : range : (sample_length - endo)
    xcor = (tail - range + 1) : tail;% x coordinates in a typical segment
    %线性拟合提参数
    foobar = polyfit(fit_foobar, line(xcor), 1);
    %AR模型提参数
    %m = ar(line(xcor),4,'ls');
    %m = ar(line(xcor),6);
    %foobar = m.A;
    vFeature = [vFeature foobar]; % IMPORTANT!!!! 
%     clear foobar
end

end