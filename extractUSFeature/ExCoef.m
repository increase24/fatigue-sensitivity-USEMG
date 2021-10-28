function [ vCoef, vCoef_no ] = ExCoef( data1, data2 )

global sampling_freq sample_length sample_depth sound_speed zero_delay chnum

if size(data1) ~= size(data2)
    error('sample length mismatched.')
end
chnum = size(data1, 1);
burst_tone_freq = 7e6; % !!IMPORTANT!! used in tgc coefficient calc and Gaussian filter mid-freq
% start = 20; % start of x
% endo = 20; % end of x, avoid gaussian filter jitter
tgc_alpha = 0.05; % [dB/(MHz cm)]   
sampling_balance = 128; % median of sampling range  %选用128更好
filter_bandwidth = 110; % in percentage 
log_comp_ratio = 0.4;
sample_length = 8*1024; % num of dots sampled
sample_depth = 63.1e-3;
sample_depth = repmat(sample_depth, 1, chnum);
sampling_freq = 100e6;
sampling_freq = repmat(sampling_freq, 1, chnum);
zero_delay = 0e-6; % lingwei yanchi in seconds
sound_speed = 1540; % m/s
% Declaration and error handling
mDepth = zeros(chnum, sample_length);
for i = 1 : chnum % channel_no
    mDepth(i, :) = (1 : sample_length) / sample_length * sample_depth(i); % mDepth contains depth value for each dot, each line for a ch
    mDepth(i, :) = sound_speed * zero_delay + mDepth(i, :);
    tgc(i, :) = exp(tgc_alpha * burst_tone_freq / 1e6 * mDepth(i, :) * 100);
%     foobar_t(i) = 1 : sample_length(i);

end
line1 = zeros(chnum, sample_length);
line2 = zeros(chnum, sample_length);
%%
for i = 1 : chnum % channel_no
    line1(i, :) = bsxfun(@times, tgc(i, :), data1(i, :) - sampling_balance); % wow, how should you know
    line1(i, :) = gaussianFilter(line1(i, :), sampling_freq(i), burst_tone_freq, filter_bandwidth); 
    line1(i, :) = envelopeDetection(line1(i, :));
%     line = smooth(line, 10)'; % smooth
    line1(i, :) = logCompression(line1(i, :), log_comp_ratio);
    line2(i, :) = bsxfun(@times, tgc(i, :), data2(i, :) - sampling_balance); % wow, how should you know
    line2(i, :) = gaussianFilter(line2(i, :), sampling_freq(i), burst_tone_freq, filter_bandwidth); 
    line2(i, :) = envelopeDetection(line2(i, :));
%     line = smooth(line, 10)'; % smooth
    line2(i, :) = logCompression(line2(i, :), log_comp_ratio);
end
vCoef = min( min( corrcoef( line1, line2 ) ) );
vCoef_no = min( min( corrcoef( data1, data2 ) ) );