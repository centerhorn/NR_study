%% Function Description
%   OFDM demodulate and Resource Element Demapping
%% Input
%   pdschConfig:  structure
%                 Configuration information for PDSCH
%   DataOfdmIn:   2-Dimensional array(UE_ANT_NUM*-(number of samples per slot))
%                 data for Demodulate
%% Output
%   DataSymMatrix: 3-Dimension array(subcarrier-symbol-port)
%                   resource grid after OFDM Demodulate
%% Modify history
% 2018/4/17 created by Liu Chunhua
% 2018/5/22 modified by Song Erhao

%% code
function [DataSymMatrix] = nrOFDMDemodulate(pdschConfig,DataOfdmIn)
BW = length(pdschConfig.PRBSet);
SUBCARRIER_PER_RB = pdschConfig.SubcarriersPerRB;
SYMBOL_PER_SUBFRAME = pdschConfig.SymbolsPerSlot;

ReFreNum = BW*SUBCARRIER_PER_RB;
ReTimeNum = SYMBOL_PER_SUBFRAME;
PortNum = size(DataOfdmIn,1);
DataSymMatrix = zeros(ReFreNum, ReTimeNum,PortNum);                                 % 系统时频资源块
%% 解OFDM调制
for PortInd=1:PortNum
    DataSymMatrix(:,:,PortInd) = OFDMDemodulate(pdschConfig,DataOfdmIn(PortInd,:));
end
end

function  output = OFDMDemodulate(pdschConfig,in)
BW = length(pdschConfig.PRBSet);
SUBCARRIER_PER_RB = pdschConfig.SubcarriersPerRB;
SYMBOL_PER_SUBFRAME = pdschConfig.SymbolsPerSlot;
IFFT_SIZE = pdschConfig.IfftSize;
LONG_CP_PERIOD = pdschConfig.LongCPPeriod;       %测试代码
CP_LONG = pdschConfig.SamplesPerLongCP;
CP_SHORT = pdschConfig.SamplesPerShortCP;

ReFreNum = BW*SUBCARRIER_PER_RB;
ReTimeNum = SYMBOL_PER_SUBFRAME;
output = zeros(ReFreNum, ReTimeNum);                                 % 系统时频资源块
PosInd =0;
%% 解OFDM调制
for TimeInd=1:ReTimeNum                                                     % 判断CP类型
    if (pdschConfig.SubcarrierSpacing == 15 && mod(TimeInd,7) == 1) ...
            || (pdschConfig.SubcarrierSpacing == 30 && TimeInd == 1) ...
            || (pdschConfig.SubcarrierSpacing == 60 && mod(gnbConfig.NSlot,2) == 0 && TimeInd == 1) ...
            || (pdschConfig.SubcarrierSpacing == 120 && mod(gnbConfig.NSlot,4) == 0 && TimeInd == 1) ...
            || (pdschConfig.SubcarrierSpacing == 240 && mod(gnbConfig.NSlot,8) == 0 && TimeInd == 1)

        %if mod(TimeInd,LONG_CP_PERIOD) == 1        %test code!!!
        temp_Cp_length = CP_LONG;
    else
        temp_Cp_length = CP_SHORT;
    end
    PosInd = PosInd + temp_Cp_length;
    data_to_FFT = in(PosInd + (1: IFFT_SIZE));                        % 去除CP，提取数据部分
    post_FFT=fft(data_to_FFT)/sqrt(IFFT_SIZE);                                % FFT变换
    output((1:(ReFreNum/2)), TimeInd)=post_FFT((IFFT_SIZE-ReFreNum/2+1) : IFFT_SIZE);  %negative part
    output(((ReFreNum/2+1):ReFreNum), TimeInd)=post_FFT(2:(ReFreNum/2+1));         %positive part
    PosInd = PosInd + IFFT_SIZE;
end

end


