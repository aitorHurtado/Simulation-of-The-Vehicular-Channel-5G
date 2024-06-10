function [channelEst,channelEst_original] = helperOFDMChannelEstimationEstReal(sysParam,pathGains,pathFilters,sampleTimes)

nfft = sysParam.FFTLen;
cpLen = sysParam.CPLen;
numSubCar = sysParam.usedSubCarr;
numLgSc = (nfft-numSubCar)/2;

Ts = 1/(sysParam.scs*sysParam.FFTLen);  % sample period
SampleRate = (1/Ts);

%,"SampleRate",SampleRate
ofdmNullIdx = [1:numLgSc (nfft/2+1) (nfft-numLgSc+2:nfft)]'; % Guard bands and DC subcarrier
nrb = numSubCar/12;

%hest = ofdmChannelResponse(pathGains,transpose(pathFilters),nfft,cpLen,setdiff(1:nfft,ofdmNullIdx),sysParam.toffset); % Nsc x Nsym x Nt x Nr

hest = nrPerfectChannelEstimate(pathGains,pathFilters,nrb,sysParam.scs/1000,0,sysParam.toffset,sampleTimes,"Nfft",nfft);

%hest = nrPerfectChannelEstimate(pathGains,pathFilters,nrb,sysParam.scs/1000,0,sysParam.toffset,sampleTimes,"Nfft",nfft,"SampleRate",SampleRate);



aux_hest = size(hest);

hestReshaped = reshape(hest,[],1,1);

aux_hestReshaped = size(hestReshaped);

channelEst = hestReshaped;
channelEst_original = hest;

end
