% This script creates a 3-D EEG matrix: [subjects samples channels]
% for ONE run: all subjects, all channels.
% Just change runIndex to 1, 2, 3, ... 12 and re-run

% Locate this script and build paths relative to it
fileName = mfilename('fullpath'); % allows a script (.m) to determine its name
thisScriptPath = fileparts(fileName); % returns the path name for the specified file => no matter from where we run the script
utilitiesPath  = fullfile(thisScriptPath, 'Utilities'); % bulids the full file 'thisScriptPath\Utilities.m'
curatedFilePath = fullfile(thisScriptPath, 'EEGMMIDB_Curated.mat');
myDatasetsPath = fullfile(thisScriptPath, "MyDatasets");
% If the path myDatasetsPath doesn't exist yet, create it
if ~exist(myDatasetsPath, 'dir') % ~ means NOT 
    mkdir(myDatasetsPath);
end

% Add the utilities path to the MATLAB search path
addpath(utilitiesPath); % includes this folder in the list of places where MATLAB look for functions (the search path at the top in my screen)

% Load the curated dataset (.mat file)
load(curatedFilePath, 'EEGMMIDB'); % loads struct EEGMMIDB from the curatedFilePath

% Retrieve the values of interest from the curated file
fs = EEGMMIDB.Frequency; % sampling frequency, constant for all subjects
nRuns = 12; % 12 runs per subject
runIndex = 2; % <<< CHANGE THE RUN INDEX MANUALLY!!!
nSubjects = size(EEGMMIDB.Subjects, 2); % 103 subjects
subjectIDs = EEGMMIDB.Subjects(2, :); % 1..103 (renumbered IDs)

% I use Subject 1 to get sizes of samples & channels (so no magic numbers are used)
subjectID_example = 1;
[eegSignalSubject1Run1, ~] = getRunOneSubject(EEGMMIDB, subjectID_example, runIndex);
[nSamples, nChannels] = size(eegSignalSubject1Run1); % returns a row vector whose elements are the lengths of the corresponding dimensions of eegSignalSubject1Run1

% Choose the precision to manage memory
% Double precision = 8 bytes per number (more accurate, uses more RAM)
% Single precision = 4 bytes per number (enough for EEG, uses half the RAM)

% Initizalize the 3D matrix using single precision
threeDMatrix = zeros(nSubjects, nSamples, nChannels, 'single'); % initialize the matrix
    
% Fill the 3-D matrix with EEG data for each subject (for Run 1)
for subjectID = 1:nSubjects
    [eegSignalOneSubjectRun1, ~] = getRunOneSubject(EEGMMIDB, subjectID, runIndex); % [19680 x 64] of Subject 1, Run 1
    threeDMatrix(subjectID, :, :) = eegSignalOneSubjectRun1; % Store the EEG data for the current subject [1 x 19680 x 64]
    % That is, for this subjectID, store all its time samples and all its channels
end

% Create the .mat file of the threeDMatrix (output). The name is automatically created based on the runIndex defined before 
outputFile = fullfile(myDatasetsPath, sprintf('Run%02d_AllSubjects_AllChannels.mat', runIndex)); % %02d means 2-digit integer 

% Save the 3-D matrix to a .mat file for future use
save(outputFile, 'threeDMatrix');


% Plot Cz (column 11) for 3 subjects
czColumnIndex  = getChannelIndex('Cz'); % extract the index/position (a scalar number) of Cz in the signal matrix
figure 
subplot(3, 1, 1);
plot(squeeze(threeDMatrix(1,:,czColumnIndex))); % squeeze() transforms the 3D matrix into a 1D or 2D array, which is what plot() expects
title('Subject 1 - Cz');
xlabel('Time (s)');
ylabel('Amplitude (\muV)');
grid on;

subplot(3, 1, 2);
plot(squeeze(threeDMatrix(2,:,czColumnIndex)));
title('Subject 2 - Cz');
xlabel('Time (s)');
ylabel('Amplitude (\muV)');
grid on;

subplot(3, 1, 3);
plot(squeeze(threeDMatrix(103,:,czColumnIndex)));
title('Subject 103 - Cz');
xlabel('Time (s)');
ylabel('Amplitude (\muV)');
grid on;

