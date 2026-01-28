function [eegSignal, annotations] = getRunOneSubject(EEGMMIDB, subjectID, runIndex)
%GETRUN Extract EEG signal and annotations for one subject and one run
%   [eegSignal, annotations] = GETRUN(EEGMMIDB, subjectID, runIndex).
%   Inputs:
%       EEGMMIDB: The loaded curated dataset structure.
%       subjectID: Integer (1..103) identifying the subject.
%       runIndex: Integer (1..12) identifying the run number.
%   Outputs:
%       eegSignal: Numeric matrix [nSamples x nChannels] = [19680 x 64]
%       annotations: Numeric matrix [30 x 5], with columns:
%                     [classLabel, durSec, durSamples, onsetIdx, endIdx]

% Retrieve the subject's signal and annotations cell names
signalNameOneSubject = sprintf('Subject_%d_Signal', subjectID); % returns the formatted string using the format specified by Subject_%d_Signal 
annotationsNameOneSubject = sprintf('Subject_%d_Annotations', subjectID);

% Retrieve the singal and annotations cell arrays of one run for the specified subject
oneSubjectOneRunSignalCell = EEGMMIDB.Signal.(signalNameOneSubject); % 1x12 cell array of the specified subject "signalNameOneSubject"
oneSubjectOneRunAnnotationsCell = EEGMMIDB.Annotations.(annotationsNameOneSubject); % 1x12 cell array of the specified annotation "annotationsNameOneSubject"

% Select the desired run 
eegSignal = oneSubjectOneRunSignalCell{runIndex}; % [19680 x 64]
annotations = oneSubjectOneRunAnnotationsCell{runIndex}; % [30 x 5]
end

