function [cdl_channelModel,antennaParam] = helperChannelSelection(channelModelParam,antennaParam,userParam,mobilityParam,antennaTx,antennaRx)

if (strcmp(channelModelParam.model,'CDL-D') || strcmp(channelModelParam.model,'CDL-E')) == true
    vision = 'LOS';
    modelo_vehicular = false;
elseif (strcmp(channelModelParam.model,'CDL-A') || strcmp(channelModelParam.model,'CDL-B') || strcmp(channelModelParam.model,'CDL-C')) == true
    vision = 'NLOS';
    modelo_vehicular = false;
elseif (strcmp(channelModelParam.model,'Urban_LOS_V2X') || strcmp(channelModelParam.model,'Urban_NLOS_V2X') || strcmp(channelModelParam.model,'Urban_vNLOS_V2X') || strcmp(channelModelParam.model,'Highway_LOS_V2X') || strcmp(channelModelParam.model,'Highway_vNLOS_V2X')) == true
    modelo_vehicular = true;
elseif (strcmp(channelModelParam.model,'No_channel')) == true
    modelo_vehicular = true;
    vision = 'LOS';
else 
    error('No se ha elegido de forma correcta el Modelo')
end

if (strcmp(channelModelParam.scenario,'UMI') || strcmp(channelModelParam.scenario,'UMA') || strcmp(channelModelParam.scenario,'RMA')) == false
    error('No se ha elegido de forma correcta el escenario')
end 

%% CDL Models and Vehicular Models
% CDL Models

if modelo_vehicular == false
    fc = userParam.fc/10^9;
    if strcmp(vision,'LOS') == true
        switch channelModelParam.scenario
            case 'UMI'
                disp('Escenario Urban Micro LOS')
                UMI_LOS_DS_mean_dB = -0.24 * log10(1 + fc) - 7.14;
                delay = 10^UMI_LOS_DS_mean_dB;

                % Factor k
                UMI_LOS_K_mean_dB = 9;
                KFactor = UMI_LOS_K_mean_dB;
            case 'UMA'
                disp('Escenario Urban Macro LOS')
                UMA_LOS_DS_mean_dB = -6.955 - 0.0963 * log10(fc);
                delay = 10^UMA_LOS_DS_mean_dB;

                % Factor k
                UMA_LOS_K_mean_dB = 9;
                KFactor = UMA_LOS_K_mean_dB;
            case 'RMA'
                disp('Escenario Rural Macro LOS')
                RMA_LOS_DS_mean_dB = -7.49;
                delay = 10^RMA_LOS_DS_mean_dB;

                % Factor k
                RMA_LOS_K_mean_dB = 7;
                KFactor = RMA_LOS_K_mean_dB;
            otherwise
                disp('Error Valor de Escenario incorrecto')
        end
    elseif strcmp(vision,'NLOS') == true
        switch channelModelParam.scenario
            case 'UMI'
                disp('Escenario Urban Micro NLOS')
                UMI_NLOS_DS_mean_dB = -0.24 * log10(1 + fc) - 6.83;
                delay = 10^UMI_NLOS_DS_mean_dB;

            case 'UMA'
                disp('Escenario Urban Macro NLOS')
                UMA_NLOS_DS_mean_dB = -6.28 - 0.204*log10(fc);
                delay = 10^UMA_NLOS_DS_mean_dB;

            case 'RMA'
                disp('Escenario Rural Macro NLOS')
                RMA_NLOS_DS_mean_dB = -7.43;
                delay = 10^RMA_NLOS_DS_mean_dB;
            otherwise
                disp('Error Valor de Escenario incorrecto')
        end
    else
        disp('Error Valor de Visión incorrecto')
    end
%Modelos Vehicular    
elseif modelo_vehicular == true
        userParam.fc = 5.9*10^9;
    if strcmp(channelModelParam.model,'Urban_LOS_V2X') == true
        DelayProfile = 'Custom';
        delay_cdl_Urban_LOS = [0.0000, 0.0000, 6.4000,12.8000,11.0793,21.9085,29.6768,36.0768,42.4768,68.4085,82.2944,115.4173,143.2963,146.4136,183.1925,214.1501,326.7825];
        delay = delay_cdl_Urban_LOS * 10^-9;
        power_cld_Urban_LOS = [-0.12,-15.52,-17.7,-19.5,-15.9,-14.6,-9.1,-11.3,-13.1,-19.3,-20.0,-16.3,-17.9,-25.4,-26.9,-22.9,-25.3];
        power = power_cld_Urban_LOS;
        anglesAOD = [0.0,0.0,0.0,0.0,93.2,85.4,-49.9,-49.9,-49.9,-97.1,108.5,-90.7,105.5,127.1,127.0,-101.5,125.2];
        anglesAOA = [-180,-180,-180,-180,-51.8,-51.9,96.8,96.8,96.8,-37.5,-45.7,57.3,-42.1,-17.6,18.6,20.6,-19.1];
        anglesZOD = [90.0,90.0,90.0,90.0,75.1,76.6,84.8,84.8,84.8,107.3,107.7,104.0,107.0,68.4,67.2,69.4,112.0];
    	anglesZOA = [90.0,90.0,90.0,90.0,57.8,119.7,100.0,100.0,100.0,130.3,130.3,58.1,52.5,36.9,145.1,42.8,141.6];
        HasLOSCluster = true;
        KFactorFirstCluster = 3.48;
        AngleSpreads = [3,17,7,7];
        XPR = 9;

    elseif strcmp(channelModelParam.model,'Urban_NLOS_V2X') == true
        DelayProfile = 'Custom';
        delay_cdl_Urban_NLOS = [0.0000,6.466311,11.6926,16.91889,19.49782,20.64838,38.74579,48.75469,53.98099,59.20728,62.18983,68.71579,70.33887,74.461,105.954,117.9043,137.072,210.5223,218.8232,232.2158,289.6542,357.7905,380.2389];
        delay = delay_cdl_Urban_NLOS * 10^-9;
        power_cld_Urban_NLOS = [-4.8,-0.8,-3,-4.8,0,-0.8,-0.9,-0.8,-3,-4.8,-6.3,-4,-8.1,-8,-7,-8.3,-1.7,-7.6,-16.2,-4.2,-18.2,-21.8,-19.9];
        power = power_cld_Urban_NLOS;
        anglesAOD = [-53,-2.7,-2.7,-2.7,-30.3,-28,28.3,0.5,0.5,0.5,-80,60,-75.7,-76.8,59.4,72.6,42.3,57.3,-93.9,-37.8,106.7,107.5,-95];
        anglesAOA = [-36,-162.5,-162.5,-162.5,-87,-79.7,-88.6,143.6,143.6,143.6,6.3,-58.2,-19.9,23,-28.7,-5.4,-82.8,-22.4,56.2,32.9,-57,-103.3,68.4];
        anglesZOD = [79.7,89.3,89.3,89.3,93.6,85.3,96,91.3,91.3,91.3,79.8,81.1,102.9,103.2,77.5,77.2,95.5,100.5,111.2,80,64.3,119.9,117];
    	anglesZOA = [12.5,73.3,73.3,73.3,73.7,121.2,119.6,92.9,92.9,92.9,175.1,29.4,159,168.3,6.9,168,134.6,21.4,84.2,171,110.2,39.6,127.9];
        HasLOSCluster = false;
        KFactorFirstCluster = -500;
        AngleSpreads = [10,22,7,7];
        XPR = 8;

    elseif strcmp(channelModelParam.model,'Urban_vNLOS_V2X') == true
        DelayProfile = 'Custom';
        delay_cdl_Urban_vNLOS = [0.0000,0.0000,20.1752,34.2552,48.3352,34.3633,37.1866,52.1209,52.7982,66.8782,80.9582,53.2168,53.2285,55.2847,65.8409,79.0272,90.9391,91.0347,105.4760,118.7946,166.1280,253.7053,293.5444,471.3768];
        delay = delay_cdl_Urban_vNLOS * 10^-9;
        power_cld_Urban_vNLOS = [-0.14,-14.93,-8.9,-11.2,-12.9,-17.9,-14.8,-11.9,-10.2,-12.5,-14.2,-11.1,-15.5,-13.8,-12.5,-20.2,-11.7,-19.0,-17.1,-17.5,-18.1,-22.2,-16.4,-19.8];
        power = power_cld_Urban_vNLOS;
        anglesAOD = [0.0,0.0,36.0,36.0,36.0,-45.7,60.7,53.6,-34.5,-34.5,-34.5,48.4,-45.8,56.0,55.7,-48.9,51.1,62.7,-43.0,62.4,-50.6,-57.0,-43.1,-50.1];
        anglesAOA = [-180,-180,138.4,138.4,138.4,-79.9,-85.1,-100.6,-119.5,-119.5,-119.5,-103.5,92.5,80.7,100.7,-69.4,101.2,69,86.5,91.5,-76.6,-68.1,82.7,-61.8];
        anglesZOD = [90.0,90.0,84.1,84.1,84.1,74.2,76.4,77.3,97.4,97.4,97.4,99.7,105.6,76.6,76.9,71.3,77.9,71.6,73.9,72.4,72.7,110.7,104.6,108.6];
    	anglesZOA = [90.0,90.0,81.1,81.1,81.1,118.1,117.3,71.3,103.0,103.0,103.0,108.7,63.7,67.0,109.3,125.9,108.3,58.4,119.8,119.9,120.3,54.1,62.1,56.4];
        HasLOSCluster = false;
        KFactorFirstCluster = -500;
        AngleSpreads = [10,22,7,7];
        XPR = 8;

    elseif strcmp(channelModelParam.model,'Highway_LOS_V2X') == true
        DelayProfile = 'Custom';
        delay_cdl_Highway_LOS = [0.0000,0.0000,2.1109,2.9528,17.0328,31.1128,9.1629,10.6761,11.0257,18.5723,19.8875,33.9675,48.0475,25.7370,36.2683,66.7093,139.9695];
        delay = delay_cdl_Highway_LOS * 10^-9;
        power_cld_Highway_LOS = [-0.07,-18.08,-19.9,-13.9,-16.2,-17.9,-14.5,-21.3,-18.7,-14.9,-16.2,-18.5,-20.2,-17.1,-13.8,-28.4,-27.4];
        power = power_cld_Highway_LOS;
        anglesAOD = [0.0,0.0,63.4,50.0,50.0,50.0,55.2,-62.6,56.0,53.3,-51.1,-51.1,-51.1,-56.1,58.4,74.7,-71.5];
        anglesAOA = [-180,-180,-80.2,98.6,98.6,98.6,73.1,-64.3,65.7,-90.9,84.5,84.5,84.5,71.3,-81.5,41.4,-42.6];
        anglesZOD = [90.0,90.0,83.8,86.9,86.9,86.9,85.1,97.3,96.3,85.3,94.4,94.4,94.4,95.5,86.2,81.1,99.4];
    	anglesZOA = [90.0,90.0,75.0,98.4,98.4,98.4,78.1,73.7,105.4,79.1,79.4,79.4,79.4,77.4,80.4,68.1,111.8];

        HasLOSCluster = true;
        KFactorFirstCluster = 9;
        AngleSpreads = [3,17,7,7];
        XPR = 9;
    elseif strcmp(channelModelParam.model,'Highway_vNLOS_V2X') == true
        DelayProfile = 'Custom';
        delay_cdl_Highway_vNLOS = [0.0000,0.0000,5.5956,19.6756,33.7556,21.7591,21.8113,27.2207,39.3242,51.0232,51.4828,53.3659,65.1775,79.2575,93.3375,67.9841,70.7561,73.9980,75.8665,84.3678,90.1654,91.6154,142.9312,158.4339];
        delay = delay_cdl_Highway_vNLOS * 10^-9;
        power_cld_Highway_vNLOS = [-0.2927,-11.8594,-12.5090,-14.7274,-16.4884,-11.8681,-11.3289,-17.8834,-9.9943,-12.7302,-13.9120,-16.8781,-12.9647,-15.1832,-16.9441,-10.7858,-12.3875,-17.3827,-14.7254,-13.5863,-20.9080,-15.5653,-19.7098,-24.7824];
        power = power_cld_Highway_vNLOS;
        anglesAOD = [0.0,0.0,-52.3,-52.3,-52.3,66.4,-46.7,89.8,-56.8,75.9,85.4,88.9,-46.2,-46.2,-46.2,-50.9,-54.3,88.3,78.0,73.5,-69.7,-62.1,-70.3,-84.5];
        anglesAOA = [-180,-180,-120,-120,-120,-114.6,96.5,77,-124.7,93.1,88.2,80.7,94.4,94.4,94.4,98.1,-99.3,66.8,91.5,-108.4,-89.6,84.4,-81.8,-69.6];
        anglesZOD = [90.0,90.0,99.2,99.2,99.2,77.2,78.6,106.8,81.2,102.1,103.7,74.0,100.0,100.0,100.0,100.2,77.7,73.8,103.8,104.8,69.4,103.2,109.1,113.8];
    	anglesZOA = [90.0,90.0,61.5,61.5,61.5,54.8,56.1,34.8,120.7,119.9,48.7,136.9,56.9,56.9,56.9,121.1,121.6,141.6,131.1,51.1,147.1,46.7,32.2,157.3];

        HasLOSCluster = false;
        KFactorFirstCluster = -500;
        AngleSpreads = [10,22,7,7];
        XPR = 8;

    elseif strcmp(channelModelParam.model,'No_channel') == true
        DelayProfile = 'Custom';
        delay_cdl_No_Channel_LOS = [0.0000];
        delay = delay_cdl_No_Channel_LOS * 10^-9;
        power_cld_No_Channel_LOS = [0.0000];
        power = power_cld_No_Channel_LOS;
        anglesAOD = [0.0];
        anglesAOA = [-180];
        anglesZOD = [90.0];
    	anglesZOA = [90.0];

        HasLOSCluster = false;
        KFactorFirstCluster = 9;
        AngleSpreads = [10,22,7,7];
        XPR = 8;
    end
end

%% Mobility
% MaximumDopplerShift (Nonnegative real number — This value specifies the maximum Doppler shift of the receiver)
c = physconst('lightspeed'); % speed of light in m/s
lambda = c/(userParam.fc);
f_doppler = (mobilityParam.v_ue*1000/3600)/lambda;     % UE max Doppler frequency in Hz

% UTDirectionOfTravel --> UTDirectionOfTravel %2-by-1 vector of real numbers of the form [RxA; RxZ] — 
% RxA and RxZ specify the azimuth and zenith of the direction of travel of the receiver UE
UTDirectionOfTravel = [mobilityParam.angulo_azimuth ; mobilityParam.angulo_zenith];

%% Channel Model
if modelo_vehicular == false
    if (strcmp(channelModelParam.model,'CDL-D') || strcmp(channelModelParam.model,'CDL-E')) == true
        K_Scaling = true;
        cdl_channelModel = nrCDLChannel(DelayProfile=channelModelParam.model,DelaySpread = delay, KFactorScaling = true, KFactor = KFactor, CarrierFrequency = userParam.fc, MaximumDopplerShift = f_doppler, UTDirectionOfTravel = UTDirectionOfTravel)
    elseif  (strcmp(channelModelParam.model,'CDL-A') || strcmp(channelModelParam.model,'CDL-B') || strcmp(channelModelParam.model,'CDL-C')) == true
        K_Scaling = false;
        cdl_channelModel = nrCDLChannel(DelayProfile=channelModelParam.model,DelaySpread = delay, CarrierFrequency = userParam.fc, MaximumDopplerShift = f_doppler,UTDirectionOfTravel = UTDirectionOfTravel)
    else
        disp('Error')
    end
elseif modelo_vehicular == true
    cdl_channelModel = nrCDLChannel(DelayProfile='Custom',PathDelays=delay,AveragePathGains=power,AnglesAoD=anglesAOD,AnglesAoA=anglesAOA,AnglesZoD=anglesZOD,AnglesZoA=anglesZOA,HasLOSCluster=HasLOSCluster,KFactorFirstCluster=KFactorFirstCluster,XPR=XPR,CarrierFrequency=userParam.fc, MaximumDopplerShift=f_doppler,UTDirectionOfTravel=UTDirectionOfTravel,AngleScaling=true,AngleSpreads=AngleSpreads)    
end


% Orient Transmit and Receive Antennas Using LOS Path Angles
if (antennaParam.AntennasAligned == 1)
    cdlInfo = cdl_channelModel.info;
    cdl_channelModel.TransmitArrayOrientation = [cdlInfo.AnglesAoD(1) cdlInfo.AnglesZoD(1)-90 0]';
    cdl_channelModel.ReceiveArrayOrientation = [cdlInfo.AnglesAoA(1) cdlInfo.AnglesZoA(1)-90 0]';
end

%% Antenna Tx
cdl_channelModel.TransmitAntennaArray.Size = [1 1 1 1 1];
cdl_channelModel.TransmitAntennaArray.ElementSpacing = antennaTx.ElementSpacing;
cdl_channelModel.TransmitAntennaArray.PolarizationAngles = antennaTx.PolarizationAngles;
cdl_channelModel.TransmitAntennaArray.Element = antennaTx.Element;
cdl_channelModel.TransmitAntennaArray.PolarizationModel = antennaTx.PolarizationModel;

%% Antenna Rx
cdl_channelModel.ReceiveAntennaArray.Size = [1 1 1 1 1];
cdl_channelModel.ReceiveAntennaArray.ElementSpacing = antennaRx.ElementSpacing;
cdl_channelModel.ReceiveAntennaArray.PolarizationAngles = antennaRx.PolarizationAngles;
cdl_channelModel.ReceiveAntennaArray.Element = antennaRx.Element;
cdl_channelModel.ReceiveAntennaArray.PolarizationModel = antennaRx.PolarizationModel;


%Transmiter Configuration
displayChannel(cdl_channelModel,'LinkEnd','Tx')
datacursormode on;
%Receiver Configuration
displayChannel(cdl_channelModel,'LinkEnd','Rx')
datacursormode on;

end 
