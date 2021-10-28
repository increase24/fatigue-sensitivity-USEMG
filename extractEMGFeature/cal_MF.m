function MF=cal_MF(signal)
sample_rate=1000;
L_emg=length(signal);
N_fft=ceil(log(L_emg)/log(2));
n_fft=2^N_fft;
spectrum_emg=fft(signal,n_fft);
ampSpectrum_emg=abs(spectrum_emg/L_emg);
singleSidedAmpSpectrum_emg = ampSpectrum_emg(1:L_emg/2+1);
singleSidedAmpSpectrum_emg(2:end-1) = 2*singleSidedAmpSpectrum_emg(2:end-1);
%figure()
f_emg = sample_rate*(0:(L_emg/2))/L_emg;
% plot(f_emg',singleSidedAmpSpectrum_emg)
% title('Single-Sided Amplitude Spectrum of X(t)')
% xlabel('f(Hz)')
% ylabel('|P(f)|')
MF=sum((f_emg'.*singleSidedAmpSpectrum_emg))/sum(singleSidedAmpSpectrum_emg);