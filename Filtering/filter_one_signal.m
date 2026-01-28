% This script is intented to filter one signal of S01_R01_Cz (Subject 1,Run 1, Electrode Cz) 

% Locate this script and build paths relative to it, since after filtering 
% I want to create another folder to store the results
thisScriptPath = fileparts(mfilename('fullpath'));
datasetsPath = fullfile(thisScriptPath, '..', 'MyDatasets');
outputsPath= fullfile(thisScriptPath, 'Outputs');
utilitiesPath  = fullfile(thisScriptPath, '..', 'Utilities');
addpath(utilitiesPath); % add Utilities

if ~exist(outputsPath, 'dir')
    mkdir(outputsPath); 
end

% Load mini .mat dataset for this script created previously in Data_extraction.m
dataFile = fullfile(datasetsPath, 'S84_R01_Cz.mat'); % dataFile is a String path
struct = load(dataFile); % I create an struct to retrieve the variables stored in the 
% .mat so they are kept safe and silent overwriting is avoided. Therefore, I work with
% a copy of the original variables 
fs = struct.FS; % Sampling frequency (the dot . is for struct field access, that is, to retrieve the variables)
eegSignal = struct.cz;

% Call the bandpass filter (Chebyshev type II) function 
[filteredDeltaSignal, filteredThetaSignal, filteredAlphaSignal, filteredBetaSignal, filteredGammaSignal] = ...
    filterEEGbands(eegSignal, fs);

% ===== Sanity checks for NaN / Inf =====
bands = {filteredDeltaSignal, filteredThetaSignal, ...
         filteredAlphaSignal, filteredBetaSignal, filteredGammaSignal};
bandNames = {'delta','theta','alpha','beta','gamma'};

for i = 1:numel(bands)
    currentBandSignal = bands{i}; % takes the i-th filtered EEG signal from the cell array bands and stores it in a variable
    fprintf('%s: NaN=%d, Inf=%d, max|x|=%g\n', ...
        bandNames{i}, any(isnan(currentBandSignal)), any(isinf(currentBandSignal)), max(abs(currentBandSignal)));
end

% FFT computations to obtain the DFT of the original vs filtered signals
signal_frec = fft(eegSignal);
filteredDeltaSignal_frec = fft(filteredDeltaSignal);

% Compute the values for the DISCRETE frequency axis ω (rad/sample) 
N = length(eegSignal); % number of points for the DFT
k = 0:N-1; % bin indices
DELTA_omega = 2*pi/N; % spacing between adjacent frequencies 
omega_axis = k * DELTA_omega; % [0, 1Δω, 2Δω, ..., (N-1)Δω]

% Compute the values for the frecuency axis f (Hz), so I can check if the
% filtered signal is between the desired cutoff frequencies in Hz
f_axis = (omega_axis * fs) / (2*pi); 

% Plot the FFT module of the original vs filtered signals
figure 
subplot(2,1,1);
plot(omega_axis, abs(signal_frec));
title('Module of the original FFT');
xlabel('ω (rad/sample)');
ylabel('|signal\_frec|');

subplot(2,1,2);
plot(omega_axis, abs(filteredDeltaSignal_frec));
title('Module of the filtered FFT');
xlabel('ω (rad/sample)');
ylabel('|filteredBetaSignal\_frec|');

figure  
subplot(2,1,1);
plot(f_axis, abs(signal_frec));
title('Module of the original FFT');
xlabel('f (Hz)');
ylabel('|signal\_frec|');

subplot(2,1,2);
plot(f_axis, abs(filteredDeltaSignal_frec));
title('Module of the filtered FFT');
xlabel('f (Hz)');
ylabel('|filteredBetaSignal\_frec|');

%filteredSignal = filtfilt(b, a, signal); % Assuming 'signal' is the variable containing the data

% Save the filtered signal to a new .mat file in the Outputs folder
%outputFile = fullfile(outputsPath, 'filtered_S01_R01_Cz.mat');
%save(outputFile, 'filteredSignal');

