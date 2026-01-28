% This script filters a 3-D EEG matrix for ONE run: [subjects x samples x channels]
% and computes features for: all subjects, all channels, all 5 EEG bands.
% It then saves: RunXX_AllSubjects_AllChannels_Features.mat
% Just change runIndex to 1, 2, 3, ... and re-run

% Locate this script and build paths relative to it
fileName = mfilename('fullpath'); % returns the full path and name of this .m file, NOT including the filename extension
thisScriptPath = fileparts(fileName); % returns the path name, file name, and extension for the specified file
myDatasetsPath = fullfile(thisScriptPath, '..', 'MyDatasets');
utilitiesPath  = fullfile(thisScriptPath, '..', 'Utilities');
% (obtained by filtering) which I want to save

% Folder where the feature .mat files will be saved (which is the output)
featuresPath= fullfile(thisScriptPath, 'Features'); 
if ~exist(featuresPath, 'dir') % ~ means NOT
    mkdir(featuresPath); 
end

% Add the utilities path to the MATLAB search path
addpath(utilitiesPath); % includes this folder in the list of places where MATLAB look for functions (the search path at the top in my screen)

% Choose which run to process
runIndex = 2; % <<< CHANGE THE RUN INDEX MANUALLY HERE!!!

% Load the 3-D.mat dataset for this run and retrieve its data (.mat created in ThreeDimensional_matrix.m)
inputFile3D = fullfile(myDatasetsPath, sprintf('Run%02d_AllSubjects_AllChannels.mat', runIndex)); 
data3DStruct = load(inputFile3D); % loads threeDMatrix, fs, runIndex, nSubjects, nSamples, nChannels, subjectIDs
threeDMatrix = data3DStruct.threeDMatrix;
% I create a struct to retrieve the variables stored in the .mat so they are kept safe and silent overwriting is avoided
% Therefore, I work with a copy of the original variables

% Initialize variables of interest
fs = 160; % sampling frequency (I knew it from EEGMMIDB.Frequency in the ThreeDimensional_matrix.m) 
[nSubjects, nSamples, nChannels] = size(threeDMatrix);  % 103, 19680, 64
subjectIDs = 1:nSubjects; % row vector (for later use in CSV/classification)
bandNames = ["delta", "theta", "alpha", "beta", "gamma"]; % put a list of strings into an array
nBands = length(bandNames); % 5
featureNames = ["mean", "variance", "power", "maxValue", ...
    "meanSpectrum", "varianceSpectrum", "maxValueSpectrum", "dominantFrequencyHz"];
nFeatures = length(featureNames); % 8
features = zeros(nSubjects, nChannels, nBands, nFeatures); % creates an array of features

% Filter into 5 bands each subject and each channel, for all samples
for subjectID = 1:nSubjects
    for channelIndex = 1:nChannels
        % Extract the signal for this subject and channel
        eegSignal = squeeze(threeDMatrix(subjectID, :, channelIndex));
        % squeeze() transforms the 3D matrix into a 1D or 2D array, as filterEEGbands() expects a 1D array

        % Check raw data integrity BEFORE filtering
        if any(~isfinite(eegSignal))
            % Returns a logical array containing 1 (true) where the elements of eegSignal are finite, and 0 (false) where they are infinite or NaN
            % If eegSignal contains complex numbers, isfinite(eegSignal) contains 1 for elements with finite real and imaginary parts, and 0 for elements where either part is infinite or NaN
            warning('RAW signal has NaN/Inf (subject=%d, channel=%d)', subjectID, channelIndex);
        end

        % Call the bandpass filter (Chebyshev type II) function 
        [deltaSignal, thetaSignal, alphaSignal, betaSignal, gammaSignal] = ...
            filterEEGbands(eegSignal, fs);

        % Create a cell array, in which each cell holds one band 
        bandSignals = {deltaSignal, thetaSignal, alphaSignal, betaSignal, gammaSignal};

        % For each band (filered signal), compute 8 features
        for bandIndex = 1:nBands
            currentBand = bandSignals{bandIndex};
            % Guard code to stop NaN/Inf values from propagating 
            if any(~isfinite(currentBand))
                warning('FILTER OUTPUT non-finite (subject=%d, channel=%d, band=%d)', ...
                    subjectID, channelIndex, bandIndex);
                currentBand(~isfinite(currentBand)) = 0;
            end

            % Time-domain features
            meanCurrentBand = mean(currentBand);
            varianceCurrentBand = var(currentBand);
            powerCurrentBand = varianceCurrentBand + (meanCurrentBand)^2;
            maxValueCurrentBand = max(currentBand);
            % Frequency-domain features
            N = length(currentBand);
            k = 0:N-1; % bin indices
            DELTA_omega = 2*pi/N; % spacing between adjacent frequencies 
            omega_axis = k * DELTA_omega; % [0, 1Δω, 2Δω, ..., (N-1)Δω], DISCRETE frequency axis ω (rad/sample) 
            f_axis = (omega_axis * fs) / (2*pi); % frecuency axis f (Hz)
            currentBand_frec = fft(currentBand);
            module_currentBand_frec = abs(currentBand_frec);

            % Guard code to stop NaN/Inf values from propagating 
            if any(~isfinite(currentBand_frec))
                warning('FFT OUTPUT non-finite (subject=%d, channel=%d, band=%d)', ...
                    subjectID, channelIndex, bandIndex);
            end

            meanSpectrumCurrentBand = mean(module_currentBand_frec);
            varianceSpectrumCurrentBand = var(module_currentBand_frec);
            [maxValueSpectrumCurrentBand, maxValueIndex] = max(module_currentBand_frec);  
            dominantFrequencyHz = f_axis(maxValueIndex); % access to maxIndex in the f_axis vector

            % Store the computed features in an array
            features(subjectID, channelIndex, bandIndex, :) = [...
                meanCurrentBand, ...
                varianceCurrentBand, ...
                powerCurrentBand, ...
                maxValueCurrentBand, ...
                meanSpectrumCurrentBand, ...
                varianceSpectrumCurrentBand, ...
                maxValueSpectrumCurrentBand, ...
                dominantFrequencyHz]; 
            % The : takes all the elements along the 4th dimension,
            % so at this subject, this channel, this band, it's filling all 8 features at once, in a [1 x 8] vector
        
        end
    end
end

% Create the .mat file of the filtered bands for this run
outputFile = fullfile(featuresPath, sprintf('Run%02d_AllSubjects_AllChannels_Features.mat', runIndex));

% Save all features to a .mat
save(outputFile, 'features', 'fs', 'runIndex', 'nSubjects', 'nSamples', 'nChannels',...
    'nBands', 'nFeatures', 'bandNames', 'featureNames','subjectIDs'); 

% Testing
fprintf('Feature matrix saved to:\n  %s\n', outputFile);
fprintf('Size of features: [%d subjects  x  %d channels  x  %d bands  x  %d features]\n', ...
        size(features,1), size(features,2), size(features,3), size(features,4));