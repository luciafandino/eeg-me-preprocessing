% Extraction of One Subject, Run 1 ∈ Task_1, electrode Cz

% Add Utilities folder with all the functions to MATLAB path 
addpath(genpath(fullfile(pwd, 'Utilities')));

% Load the curated MATLAB file
load('EEGMMIDB_Curated.mat'); 

% Quick sanity checks
FS = EEGMMIDB.Frequency; % sampling frequency, constant for all subjects
assert(FS == 160, 'Unexpected sampling rate');

% Extract subject and run
subjectID = 84; % Subject 84
runIndex = 1; % Run 1 (Task 1: ME–unilateral)  [curated order: 1..12]
[eegSignal, annotations] = getRunOneSubject(EEGMMIDB, subjectID, runIndex);

% Extract the Cz channel 
czColumnIndex  = getChannelIndex('Cz'); % extract the index/position (a scalar number) of Cz in the signal matrix, 11
cz = eegSignal(:, czColumnIndex); % extract the actual signal from the EEG data using czColumnIndex 

% Plot the extracted signal
N  = length(cz); % number of samples (19680)
T  = 1/FS; % sampling period (seconds per sample)
t  = (0:N-1) * T; % time vector in seconds (row vector); first sample starts at 0 sec.
t  = t(:); % ensure it's a column, to match cz
plot(t, cz, 'LineWidth', 1);
xlabel('Time (s)');
ylabel('Amplitude (\muV)');
title('Subject 84 - Run 1 - Cz (continuous)');
grid on;
xlim([0, (N-1)*T]);

% The lines commented above were my first approach to create a .mat in the same path as this script
% Save only the variables of interest into one .mat file
%save S01_R01_Cz.mat FS subjectID runIndex czColumnIndex cz 

% Clear them out of the workspace
%clear FS subjectID runIndex czColumnIndex cz

% Load them again
%load S01_R01_Cz.mat

% My second approach:
% Create a a MyDatasets folder relative to this script (more portable)
thisScriptPath = fileparts(mfilename('fullpath')); % path of the running script
outputPath = fullfile(thisScriptPath, "MyDatasets");

% If the path outputPath doesn't exist yet, create it
if ~exist(outputPath, 'dir') % ~ means NOT 
    mkdir(outputPath);
end

% Create the .mat file 
outputFile = fullfile(outputPath, 'S84_R01_Cz.mat');

% Save only the variables of interest into one .mat file
save(outputFile, 'FS', 'subjectID', 'runIndex', 'czColumnIndex', 'cz'); % pass the variables names as strings, 
% as it is what the function save() expects
