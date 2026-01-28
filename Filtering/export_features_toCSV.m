% This script loads feature .mat files for Run 1 (Relax) and Run 2 (Left Fist),
% flattens them into a single table, and exports one CSV for Altair

% Locate this script and build paths relative to it
fileName = mfilename('fullpath'); % returns the full path and name of this .m file, NOT including the filename extension
thisScriptPath = fileparts(fileName); % returns the path name, file name, and extension for the specified file
myDatasetsPath = fullfile(thisScriptPath, '..', 'MyDatasets');
featuresPath= fullfile(thisScriptPath, 'Features'); 

% Load features.mat for Run 1 and Run 2 and retrieve its data
featuresFileRun1 = fullfile(featuresPath, 'Run01_AllSubjects_AllChannels_Features.mat');
featuresFileRun2 = fullfile(featuresPath, 'Run02_AllSubjects_AllChannels_Features.mat');
structRun1 = load(featuresFileRun1);
structRun2 = load(featuresFileRun2);

featuresRun1 = structRun1.features; % array containing nSubjects, nChannels, nBands, nFeatures
featuresRun2 = structRun2.features;
nSubjects = structRun1.nSubjects; % 103
nChannels = structRun1.nChannels; % 64
nBands = structRun1.nBands; % 5 
nFeatures = structRun1.nFeatures; % 8
bandNames = structRun1.bandNames;
featureNames = structRun1.featureNames;
subjectIDs = structRun1.subjectIDs(:); % colon reshapes subjectIDs (row vector) into a column vector
run1Index = structRun1.runIndex; % 1
run2Index = structRun2.runIndex; % 2

% Define the labels of each run
labelRun1 = "Relax"; % Task 1, Run 1 -> Relax
labelRun2 = "LeftFist"; % Task 1, Run 2 -> Left Fist

% Define the variables for the CSV 
nRowsPerRun = nSubjects * nChannels * nBands;
nRowsTotal  = 2 * nRowsPerRun; % *2 since we have 2 runs
subjectColumn = zeros(nRowsTotal, 1);
channelColumn = zeros(nRowsTotal, 1);
bandColumn = strings(nRowsTotal, 1);
runColumn = zeros(nRowsTotal, 1);
labelColumn = strings(nRowsTotal, 1);
featureMatrix = zeros(nRowsTotal, nFeatures); % to combine features of Run 1 and Run 2

% Flatten features of both runs into one table
currentRow = 0;

for run = 1:2
    if run == 1
        feature = featuresRun1;
        runIndex = run1Index;
        label = labelRun1;
    else
        feature = featuresRun2;
        runIndex = run2Index;
        label = labelRun2; 
    end

    for subject = 1:nSubjects
        for channel = 1:nChannels
            for band = 1:nBands
                currentRow = currentRow + 1;
                subjectColumn(currentRow) = subjectIDs(subject);
                channelColumn(currentRow) = channel;
                bandColumn(currentRow) = bandNames(band);
                runColumn(currentRow) = runIndex;
                labelColumn(currentRow) = label;
                % Fill the features matrix taking into account the dimensions
                featureColumnVector = squeeze(feature(subject, channel, band, :)); % turns 1×1×1×8 into 8×1
                featureMatrix(currentRow, :) = featureColumnVector.'; % .' computes the transpose of featureColumnVector (8x1 into 1x8)
                % since featureMatrix size is nRowsTotal x 8 => dimensions
                % match and the assignation of values can be done 
            end
        end
    end
end 

% Build the table: metadata + feature columns -> table = the easiest bridge between Matlab data and CSV
metadataNames = {'Subject', 'Channel', 'Band', 'Run', 'Label'};
metadataTable = table(subjectColumn, channelColumn, bandColumn, runColumn,...
    labelColumn, 'VariableNames', metadataNames);
% 'VariableNames' is a keyword Matlab uses to know that the following
% variable contains the column names that will appear in the table 

featuresTable = array2table(featureMatrix, 'VariableNames', featureNames); % converts an m-by-n array to an m-by-n table 

finalTable = [metadataTable, featuresTable];

% Write the CSV
csvFile = fullfile(myDatasetsPath, 'Run01_02_AllSubjects_AllChannels_Features.csv'); % builds the path to write to
writetable(finalTable, csvFile); % actually writes the csv
