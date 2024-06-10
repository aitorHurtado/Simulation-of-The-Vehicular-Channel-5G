function [rxOut,pathGains,pathFilters,sampleTimes,sysParam] = helperOFDMChannel(txIn,chanParam,sysParam,frameNum,antennaParam,userParam)
%helperOFDMChannel() Generate channel impairments.
%   This function generates channel impairments and applies them to the
%   input waveform.
%   rxOut = helperOFDMChannel(txIn,chanParam,sysParam)
%   txIn - input time-domain waveform
%   chanParam - structure of channel impairment parameters
%   sysParam - structure of system parameters
%   rxOut - output time-domain waveform
%
%   The channel parameters specify the level of impairments:
%
%   Normalized Doppler shift - Doppler frequency times symbol duration
%   Path delays and gains - Vector of path delays and average gains
%   SNR - in dB
%   Normalized carrier frequency offset (ppm) - tx/rx frequency offset
%   divided by the sample rate. Though processing is done in the baseband, it
%   is assumed that carrier offset is preserved when down-converting to DC. 

% Copyright 2022 The MathWorks, Inc.

symLen = (sysParam.FFTLen+sysParam.CPLen);

% Create a persistent channel filter object for channel fading


Ts = 1/(sysParam.scs*sysParam.FFTLen);  % sample period
T = symLen*Ts;                          % symbol duration (s)
fmax = chanParam.doppler/T;

%% Apply CDL Channel Model
% Modify Channel CDL

if frameNum == 1
    chanParam.cdl.release();
    chanParam.cdl.MaximumDopplerShift = fmax;
    if strcmp(antennaParam.antennaSystem,"est_ofdmChannelResponse") == true

        % chanParam.cdl.SampleDensity = Inf;
        
        %chanParam.cdl.SampleRate = (1/Ts)*2;
        if strcmp(chanParam.model,'CDL-A') == true
            chanParam.cdl.SampleRate = (1/Ts);
            chanParam.cdl.SampleDensity = Inf;
        elseif strcmp(chanParam.model,'CDL-B') == true
            chanParam.cdl.SampleRate = (1/Ts);
            chanParam.cdl.SampleDensity = Inf;
        elseif strcmp(chanParam.model,'CDL-C') == true
            chanParam.cdl.SampleRate = (1/Ts); 
            chanParam.cdl.SampleDensity = Inf;
        elseif strcmp(chanParam.model,'CDL-D') == true
            chanParam.cdl.SampleRate = (1/Ts);
            chanParam.cdl.SampleDensity = Inf;
        elseif strcmp(chanParam.model,'CDL-E') == true 
            chanParam.cdl.SampleRate = (1/Ts);
            chanParam.cdl.SampleDensity = Inf;        
        elseif strcmp(chanParam.model,'Urban_LOS_V2X') == true 
            chanParam.cdl.SampleRate = (1/Ts);
            chanParam.cdl.SampleDensity = Inf;        
        elseif strcmp(chanParam.model,'Urban_NLOS_V2X') == true 
            chanParam.cdl.SampleRate = (1/Ts);
            chanParam.cdl.SampleDensity = Inf;        
        elseif strcmp(chanParam.model,'Urban_vNLOS_V2X') == true 
            chanParam.cdl.SampleRate = (1/Ts);
            chanParam.cdl.SampleDensity = Inf;        
        elseif strcmp(chanParam.model,'Highway_LOS_V2X') == true 
            chanParam.cdl.SampleRate = (1/Ts);
            chanParam.cdl.SampleDensity = Inf;        
        elseif strcmp(chanParam.model,'Highway_vNLOS_V2X') == true 
            chanParam.cdl.SampleRate = (1/Ts); 
            chanParam.cdl.SampleDensity = Inf;       
        end
    end
end

% Pass Signal Through Channel CDL
[fadingChanOut,pathGains,sampleTimes] = chanParam.cdl(txIn);

aux_pathGains = size(pathGains); 

pathFilters = getPathFilters(chanParam.cdl);

aux_pathFilters = size(pathFilters);

channelInfo = info(chanParam.cdl);

sysParam.toffset = channelInfo.ChannelFilterDelay;

if userParam.enablePFO == 1
    persistent pfo;
    if isempty(pfo)
        pfo = comm.PhaseFrequencyOffset(...
            SampleRate=1e6, ...    % Phase-frequency offset is specified in PPM
            FrequencyOffsetSource="Input port");
    end 
end

% AWGN
txScaleFactor = sysParam.usedSubCarr/(sysParam.FFTLen^2);
signalPowerDbW = 10*log10(txScaleFactor);
[rxChanOut,nVar] = awgn(fadingChanOut,chanParam.SNR,signalPowerDbW);

sysParam.nVar = nVar;
% Carrier frequency offset
if userParam.enablePFO == 1
    rxOut = pfo(rxChanOut,chanParam.foff);
else
    rxOut = rxChanOut;
end

end

