function [toffset,packetDetected] = helperOFDMFrameSync(dataIn,sysParam)
%helperOFDMFrameSync Performs input frame alignment.
%   This function performs frame synchronization by correlating the input
%   sequence 'SyncSignal' with input 'dataIn'. It will look for maximum
%   correlation value and aligns the input data and aligned output data
%   'dataOut' with timing offset 'toffset'.
%
%   [toffset,packetDetected] = helperOFDMFrameSync(dataIn,sysParam)
%   dataIn - time-domain input waveform
%   sysParam - structure of system parameters
%   toffset - timing offset values indicating the first sample after the
%   sync symbol
%   packetDetected - boolean to indicate if sync symbol was detected

% Copyright 2020-2022 The MathWorks, Inc.

% Construct the sync signal
FFTLength = sysParam.FFTLen;
syncPad   = (FFTLength - 62)/2;
syncNulls = [1:syncPad (FFTLength/2)+1 FFTLength-syncPad+2:FFTLength]';
Pt = ofdmmod(helperOFDMSyncSignal(),FFTLength,0,syncNulls);
w0 = flipud(conj(Pt));
syncSignal = w0/sqrt(w0'*w0); % Normalize energy of each sequence to 1.

frameLength = (FFTLength + sysParam.CPLen)*sysParam.numSymPerFrame;
corrLen = FFTLength;

% Correlate the sync signal with the received signal
corr = filter(syncSignal,1,dataIn);

% Calculate absolute of complex filter output
sum_abs_corr = (abs(corr)).^2 ;

% Perform thresholding on dataIn
dataThresholded = abs(dataIn*0.6).^2; % correlation threshold to indicate presence of sync

% Apply moving average filter over length of FFT
movingFiltOut = cumsum(dataThresholded-[zeros(corrLen,1);dataThresholded(1:end-corrLen)]);
lowerLimit = corrLen * 2^-24;
lowerValues  =  movingFiltOut < lowerLimit;
movingFiltOut(lowerValues) = lowerLimit;
corrLoc = sum_abs_corr < movingFiltOut; % mark all indices where signal power is less than threshold
corrAfterThreshold = sum_abs_corr;
corrAfterThreshold(corrLoc) = 0;

% Find first instance of sync signal
[~,maxindex] = max(corrAfterThreshold(1:frameLength));
if corrLoc(maxindex)==0 % verify maxindex falls above the threshold
    packetDetected = true;
    toffset = maxindex;
else
    packetDetected = false;
    toffset = [0];
end

end