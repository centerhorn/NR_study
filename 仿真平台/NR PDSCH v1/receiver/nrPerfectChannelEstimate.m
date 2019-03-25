%% Function Description
%  ideal channel estimination
%% Input
%  pdsch£ºstruct. 
%             pdsch configuration.
%  channel: struct. 
%            channel configuration.
%  H: matrix. 
%            channel gains in time field.
%  delayout: vector. 
%            the delay in sampling dot for all paths.
%  PrecodingMatrix: matrix. 
%            the precoding matrix in the moment.
%% Output
%  estChannelGrid£ºmatrix.
%          channel gains in frequency field.
%% Modify History
%  2018/04/18 created by Liu Chunhua 
%%
function estChannelGrid = nrPerfectChannelEstimate(pdsch,channel,H,PrecodingMatrix)

IFFT_SIZE = channel.IFFTSize;
LONG_CP_PERIOD = pdsch.LongCpPeriod;
CP_LONG = pdsch.LongCp;
CP_SHORT = pdsch.ShortCp;
ReTimeNum = pdsch.SymbolPerSlot;
NB_ANT_NUM = channel.NBAntNum;
UE_ANT_NUM = channel.UEAntNum;
RANK = pdsch.Rank;
delayout = channel.DelayOut;
MAX_DELAY=channel.MaxDelay;

% Generate training sequence for ideal channel estimination
TrainOfdmTemp = [];
fft_size_minus = IFFT_SIZE-1;
for TimeInd = 1 : ReTimeNum
    if mod(TimeInd,LONG_CP_PERIOD) == 1                                                     
        TempCpLength = CP_LONG;
    else 
        TempCpLength = CP_SHORT;
    end    
    TrainOfdmTemp = [TrainOfdmTemp,zeros(1,TempCpLength), 1, zeros(1,fft_size_minus)];
end
TrainOfdmOut = ones(NB_ANT_NUM,1)*TrainOfdmTemp;

% training sequence pass channel
PreInterfere = zeros(NB_ANT_NUM*UE_ANT_NUM,MAX_DELAY);
[TrainAfterChannel, ~] = PassChannel(TrainOfdmOut,PreInterfere,H,channel);

% channel estimination
HIdeal = [];
for AntInd = 1:NB_ANT_NUM*UE_ANT_NUM
    estChannelGridPerPath = nrOFDMDemodulate(pdsch, TrainAfterChannel) * sqrt(IFFT_SIZE);    
    HIdeal = [HIdeal;estChannelGridPerPath(1:end)];
end

% precoding 
HIdealF=[];
for m = 1:length(HIdeal)
   HIdealT = reshape(HIdeal(:,m),NB_ANT_NUM,UE_ANT_NUM);
   HIdealF1 = HIdealT.'*PrecodingMatrix;
   HIdealF2 = reshape(HIdealF1.',RANK*UE_ANT_NUM,1);
   HIdealF=[HIdealF,HIdealF2];
end

% get the estiminated H grid
estChannelGrid = zeros(size(estChannelGridPerPath,1),size(estChannelGridPerPath,2),RANK*UE_ANT_NUM);
for Ind = 1:RANK*UE_ANT_NUM
    estChannelGridTemp = zeros(size(estChannelGridPerPath,1),size(estChannelGridPerPath,2));
    estChannelGridTemp(1:end) = HIdealF(Ind, :);
    estChannelGrid(:,:,Ind) = estChannelGridTemp;
end

end