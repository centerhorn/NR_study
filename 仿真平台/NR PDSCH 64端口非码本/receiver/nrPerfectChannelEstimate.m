%% Function Description
%  ideal channel estimination
%% Input
%  pdschConfig£º  structure. 
%                 pdsch configuration.
%  gnbConfig :    structure
%                 gNB   configuration
%  channel:       structure. 
%                 channel configuration.
%  H:             matrix. 
%                 channel gains in time field.
%  PrecodingMatrix: 2-Dimension array(portNums-layerNums)
%                   codebook for precoding
%  RS_MAP_MATRIX  : 3-dimensional array (subcarrier-symbol-rank).
%                   resource mapping matrix           
%  PortMappingMat: 2-Dimension array(TxAntNum-PortNum)
%                  Mapping Matrix of Port to Antenna
%% Output
%  HIdealCSIRS   :2-Dimension array(RxAntNum*PortNum-DataNum)
%
%  HIdealF       :2-Dimension array(RxAntNum-DataNum)
%% Modify History
%  2018/04/18 created by Liu Chunhua 
%%
function [HIdealCSIRS,HIdealF] = nrPerfectChannelEstimate(pdschConfig,gnbConfig,channel,H,PrecodingMatrix,RS_MAP_MATRIX,PortMappingMat)

IFFT_SIZE = channel.IfftSize;
CP_LONG = pdschConfig.SamplesPerLongCP;
CP_SHORT = pdschConfig.SamplesPerShortCP;
ReTimeNum = pdschConfig.SymbolsPerSlot;
NB_ANT_NUM = channel.NBAntNum;
UE_ANT_NUM = channel.UEAntNum;
RANK = pdschConfig.Rank;
PortCSIRS = pdschConfig.PortCSIRS;
delayout = channel.DelayOut;
MAX_DELAY=channel.MaxDelay;

% Generate training sequence for ideal channel estimination
TrainOfdmTemp = [];
fft_size_minus = IFFT_SIZE-1;
for TimeInd = 1 : ReTimeNum
    %if mod(TimeInd,LONG_CP_PERIOD) == 1
    if (pdschConfig.SubcarrierSpacing == 15 && mod(TimeInd,7) == 1) ...
            || (pdschConfig.SubcarrierSpacing == 30 && TimeInd == 1) ...
            || (pdschConfig.SubcarrierSpacing == 60 && mod(gnbConfig.NSlot,2) == 0 && TimeInd == 1) ...
            || (pdschConfig.SubcarrierSpacing == 120 && mod(gnbConfig.NSlot,4) == 0 && TimeInd == 1) ...
            || (pdschConfig.SubcarrierSpacing == 240 && mod(gnbConfig.NSlot,8) == 0 && TimeInd == 1)
        TempCpLength = CP_LONG;
    else 
        TempCpLength = CP_SHORT;
    end    
    TrainOfdmTemp = [TrainOfdmTemp,zeros(1,TempCpLength), 1, zeros(1,fft_size_minus)];
end
TrainOfdmOut = ones(NB_ANT_NUM,1)*TrainOfdmTemp;

% training sequence pass channel
PreInterfere = zeros(NB_ANT_NUM*UE_ANT_NUM,MAX_DELAY);
[TrainAfterChannel, ~] = PassChannelTrain(TrainOfdmOut,PreInterfere,H,channel);

%channel estimination
HIdeal = [];
for AntInd = 1:NB_ANT_NUM*UE_ANT_NUM
    HIdealTemp = Ideal_Channel_Estimation(TrainAfterChannel(AntInd,:),pdschConfig,gnbConfig,RS_MAP_MATRIX(:,:,1));
    HIdeal = [HIdeal;HIdealTemp];
end
% precoding 
HIdealF=[];
% for m = 1:length(HIdeal)
for m = 1:size(HIdeal,2)
   HIdealT = reshape(HIdeal(:,m),NB_ANT_NUM,UE_ANT_NUM);
   HIdealF1 = HIdealT.'*PortMappingMat*PrecodingMatrix;
   HIdealF2 = reshape(HIdealF1.',RANK*UE_ANT_NUM,1);
   HIdealF=[HIdealF,HIdealF2];
end

HIdealCSIRS=[];
for m = 1:size(HIdeal,2)
   HIdealT = reshape(HIdeal(:,m),NB_ANT_NUM,UE_ANT_NUM);
   HIdealCSI1 = HIdealT.'*PortMappingMat;
   HIdealCSI2 = reshape(HIdealCSI1.',PortCSIRS*UE_ANT_NUM,1);
   HIdealCSIRS=[HIdealCSIRS,HIdealCSI2];
end

end