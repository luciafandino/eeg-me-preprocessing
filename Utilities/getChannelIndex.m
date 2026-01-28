function channelIndex = getChannelIndex(channelName)
%GETCHANNELINDEX Return the numeric column index for a given EEG channel name.
%   Detailed explanation goes here:
%   channelIndex = GETCHANNELINDEX(channelName)
%
%   This function maps the standard 10–10 electrode names used in the
%   curated EEG Motor Movement/Imagery dataset (EEGMMIDB) to their
%   corresponding column indices in the signal matrix [samples x 64].
%
%   INPUT:
%       channelName: String or character vector with the electrode name,
%                    e.g., 'Cz', 'C3', 'Fz', etc. (case-insensitive)
%
%   OUTPUT:
%       channelIndex: Integer (1–64) column index in the EEG signal matrix.
%
%   EXAMPLE:
%       idx = getChannelIndex('Cz');
%       czSignal = eegSignal(:, idx);
%
%   NOTES:
%       • The current implementation includes a minimal subset of channels,
%       which are the ones with most relevance in this study.
%       Extend this mapping as needed based on the montage used in the PhysioNet 
%       EEGMMIDB dataset.
%       • The dataset stores channels in a fixed order; Cz is column 11.

    % Extract the input name (remove spaces, force uppercase)
    channelName = upper(strtrim(channelName));

    % Map the electode names to their indeces (extend later if needed)
    switch channelName
        case 'FP1', channelIndex = 1;
        case 'FPZ', channelIndex = 2;
        case 'FP2', channelIndex = 3;
        case 'F7',  channelIndex = 4;
        case 'F3',  channelIndex = 5;
        case 'FZ',  channelIndex = 6;
        case 'F4',  channelIndex = 7;
        case 'F8',  channelIndex = 8;
        case 'FC5', channelIndex = 9;
        case 'FC1', channelIndex = 10;
        case 'CZ',  channelIndex = 11;  % Central midline electrode
        case 'FC2', channelIndex = 12;
        case 'FC6', channelIndex = 13;
        % (We can continue this list gradually as needed)
        otherwise
            error('Unknown or unmapped channel name: "%s".', channelName);
    end
end