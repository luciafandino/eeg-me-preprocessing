function [filteredDeltaSignal, filteredThetaSignal, filteredAlphaSignal, filteredBetaSignal, filteredGammaSignal] = filterEEGbands(eegSignal, fs)
%FILTEREEGBANDS receives one input EEG signal and returns its 5 filtered bands
%   Detailed explanation goes here

% Build the bandpass filter (Chebyshev type II) 
fc1 = [0.5, 4]; % cutoff frequencies (Hz) for the δ band
fc2 = [4, 7]; % cutoff frequencies (Hz) for θ band 
fc3 = [8, 12]; % cutoff frequencies (Hz) for the α band 
fc4 = [13, 30]; % cutoff frequencies (Hz) for the β band 
fc5 = [30, 45]; % cutoff frequencies (Hz) for the γ band
Wcn1 = fc1 / (fs/2); % normalization of the cutoff freq. (Hz) to Nyquist (0–1)
Wcn2 = fc2 / (fs/2);
Wcn3 = fc3 / (fs/2);
Wcn4 = fc4 / (fs/2);
Wcn5 = fc5 / (fs/2);
 
n = 4; % order of the filter (CHANGED FROM 1O TO 4, 10 is too high here)
Rs = 40; % stopband attenuation in dB (CHANGED FROM 80 TO 40) 40 dB is usually enough, 80 dB can destabilize

% NOTE: I used sos for delta and theta (lowest frequency bands) as they became unstable when scaling the filtering
[b1, a1] = cheby2(n, Rs, Wcn1, "bandpass"); % a, b are the transfer function coefficients of the filter
[sos1, g1] = tf2sos(b1, a1); % finds a matrix sos in second-order section form with gain g that is equivalent 
% to the digital filter represented by transfer function coefficient vectors b and a.
% sos: second-order section coefficients. This is the standard way to stabilize high-order IIR filters
[b2, a2] = cheby2(n, Rs, Wcn2, "bandpass");
[sos2, g2] = tf2sos(b2, a2);
[b3, a3] = cheby2(n,Rs,Wcn3, "bandpass"); 
[b4, a4] = cheby2(n,Rs,Wcn4, "bandpass");
[b5, a5] = cheby2(n,Rs,Wcn5, "bandpass");

% Apply the bandpass filter (Chebyshev type II) to the input signal
filteredDeltaSignal = filtfilt(sos1, g1, eegSignal); % ------ I'VE TRIED TO USE FILTFILT INSTEAD OF FILTER
filteredThetaSignal = filtfilt(sos2, g2, eegSignal);
filteredAlphaSignal = filtfilt(b3, a3, eegSignal);
filteredBetaSignal = filtfilt(b4, a4, eegSignal);
filteredGammaSignal = filtfilt(b5, a5, eegSignal);

end