%% Function Description
%  OFDM Modulate
%% Input
%  gnbConfig: structure
%             configuration information for gNB
%  pdschConfig : structure
%                configuration information for PDSCH
%  DataIn: 3-dimensional array (subcarrier-symbol-port).
%          data after resource mapping
%% Output
%  DataOut：2-dimensional array(ports-symbols)
%           symbols after OFDMModulate
%% Modify History
% 2018/4/17 created by Liu Chunhua 
% 2018/5/17 modified by Song Erhao(editorial changes only)

%% code
function [DataOut] = nrOFDMModulate(gnbConfig, pdschConfig,DataIn)
IFFT_SIZE = pdschConfig.IfftSize;
T = pdschConfig.Ts;  % number of samples per slot
LONG_CP_PERIOD = pdschConfig.LongCPPeriod;         %test code!!!
CP_LONG = pdschConfig.SamplesPerLongCP;
CP_SHORT = pdschConfig.SamplesPerShortCP;
IsUseDC = false;          %测试改为了false

%% OFDM调制
DataOut = [];
[ReFreNum, ReTimeNum,TxAntNum] = size(DataIn);
for TxAntInd = 1:TxAntNum
    TimeDomainFramePort0 = zeros(1,T);
    PosInd =0;
    SymOfdmIn = DataIn(:,:,TxAntInd);
    for TimeInd = 1 : ReTimeNum
        %frequency mapping
        DataToIFFT = zeros(1,IFFT_SIZE);
        if (IsUseDC)
            DataToIFFT(1:ReFreNum/2) = SymOfdmIn((ReFreNum/2+1):ReFreNum, TimeInd);               % positive part, including DC
            DataToIFFT((IFFT_SIZE-ReFreNum/2+1):IFFT_SIZE) = SymOfdmIn(1:(ReFreNum/2), TimeInd);  % negative part
        else
            DataToIFFT(2:(ReFreNum/2+1)) = SymOfdmIn((ReFreNum/2+1):ReFreNum, TimeInd);           % positive part, excluding DC
            DataToIFFT((IFFT_SIZE-ReFreNum/2+1):IFFT_SIZE) = SymOfdmIn(1:(ReFreNum/2), TimeInd);  % negative part
        end
        PostIFFT = sqrt(IFFT_SIZE)*ifft(DataToIFFT,IFFT_SIZE);                               % IFFT变换

%         if (pdschConfig.SubcarrierSpacing == 15 && mod(TimeInd,7) == 1) ...
%             || (pdschConfig.SubcarrierSpacing == 30 && TimeInd == 1) ...
%             || (pdschConfig.SubcarrierSpacing == 60 && mod(gnbConfig.NSlot,2) == 0 && TimeInd == 1) ...
%             || (pdschConfig.SubcarrierSpacing == 120 && mod(gnbConfig.NSlot,4) == 0 && TimeInd == 1) ...
%             || (pdschConfig.SubcarrierSpacing == 240 && mod(gnbConfig.NSlot,8) == 0 && TimeInd == 1)

         if mod(TimeInd,LONG_CP_PERIOD) == 1        %test code!!!
            TempCpLength = CP_LONG;
        else 
            TempCpLength = CP_SHORT;
        end
        %construct the subframe by symbols
        TimeDomainFramePort0(PosInd+(1:TempCpLength)) = PostIFFT((IFFT_SIZE-TempCpLength+1):end);  % CP部分
        PosInd = PosInd + TempCpLength;
        TimeDomainFramePort0(PosInd+(1:IFFT_SIZE)) = PostIFFT;                                         % 数据部分
        PosInd = PosInd + IFFT_SIZE;
    end
    DataOut = [DataOut;TimeDomainFramePort0];
end

end

