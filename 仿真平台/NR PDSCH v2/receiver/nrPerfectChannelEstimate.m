%% Function Description
%  ideal channel estimination
%% Input
%  pdschConfig£º    struct.
%             pdsch configuration.
%  channel:   struct.
%             channel configuration.
%  H:        matrix.
%            channel gains in time field.
%% Output
%  estChannelGrid£ºmatrix.
%          channel gains in frequency field.
%% Modify History
%  2018/04/18 created by Liu Chunhua
%%
function estChannelGrid = nrPerfectChannelEstimate(pdschConfig,channel,H)

IFFT_SIZE = channel.IfftSize;
CP_LONG = pdschConfig.SamplesPerLongCP;
CP_SHORT = pdschConfig.SamplesPerShortCP;
ReTimeNum = pdschConfig.SymbolsPerSlot;
NB_ANT_NUM = channel.NBAntNum;
UE_ANT_NUM = channel.UEAntNum;
RANK = pdschConfig.Rank;
delayout = channel.DelayOut;
MAX_DELAY=channel.MaxDelay;

% Generate training sequence for ideal channel estimination
TrainOfdmTemp = [];
fft_size_minus = IFFT_SIZE-1;
for TimeInd = 1 : ReTimeNum
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
TrainAfterChannel = TrainPassChannel(TrainOfdmOut,PreInterfere,H,channel);

% channel estimination
HIdeal = [];
for AntInd = 1:NB_ANT_NUM*UE_ANT_NUM
    estChannelGridPerPath = nrOFDMDemodulate(pdschConfig, TrainAfterChannel) * sqrt(IFFT_SIZE);
    HIdeal = [HIdeal;estChannelGridPerPath(1:end)];
end

% % precoding
% HIdealF=[];
% for m = 1:length(HIdeal)
%     HIdealT = reshape(HIdeal(:,m),NB_ANT_NUM,UE_ANT_NUM);
%     HIdealF1 = HIdealT.'*pdschConfig.Codebook;
%     HIdealF2 = reshape(HIdealF1.',RANK*UE_ANT_NUM,1);
%     HIdealF=[HIdealF,HIdealF2];
% end

% % get the estiminated H grid
% estChannelGrid = zeros(size(estChannelGridPerPath,1),size(estChannelGridPerPath,2),RANK*UE_ANT_NUM);
% for Ind = 1:RANK*UE_ANT_NUM
%     estChannelGridTemp = zeros(size(estChannelGridPerPath,1),size(estChannelGridPerPath,2));
%     estChannelGridTemp(1:end) = HIdealF(Ind, :);
%     estChannelGrid(:,:,Ind) = estChannelGridTemp;
% end

end