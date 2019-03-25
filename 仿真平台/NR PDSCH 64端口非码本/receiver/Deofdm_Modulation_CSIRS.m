%% 函数功能：
% 对输入的数据进行解OFDM调制和解资源映射
%% 输入参数：
% DataOfdmIn：待解调的数据流
% CSIRS_MAP：资源映射矩阵
% pdschConfig:
%% 输出参数
% PilotSymOut：解调及解资源映射后的DMRS
%% Modify history
% 2018/1/17 created by Liu Chunhua
%% code
function [ PilotSymOut] = Deofdm_Modulation_CSIRS(DataOfdmIn,CSIRS_MAP,pdschConfig)
IFFT_SIZE = pdschConfig.IfftSize;
CP_LONG = pdschConfig.SamplesPerLongCP;
CP_SHORT = pdschConfig.SamplesPerShortCP;
LONG_CP_PERIOD = pdschConfig.LongCPPeriod;    %test code!!!
[ReFreNum, ReTimeNum] = size(CSIRS_MAP);
DataSymMatrix = zeros(ReFreNum, ReTimeNum);                                 % 系统时频资源块
PosInd =0;
%% 解OFDM调制
for TimeInd=1:ReTimeNum                                                     % 判断CP类型
    %if mod(TimeInd,LONG_CP_PERIOD) == 1
    if (pdschConfig.SubcarrierSpacing == 15 && mod(TimeInd,7) == 1) ...
            || (pdschConfig.SubcarrierSpacing == 30 && TimeInd == 1) ...
            || (pdschConfig.SubcarrierSpacing == 60 && mod(gnbConfig.NSlot,2) == 0 && TimeInd == 1) ...
            || (pdschConfig.SubcarrierSpacing == 120 && mod(gnbConfig.NSlot,4) == 0 && TimeInd == 1) ...
            || (pdschConfig.SubcarrierSpacing == 240 && mod(gnbConfig.NSlot,8) == 0 && TimeInd == 1)
        temp_Cp_length = CP_LONG;
    else
        temp_Cp_length = CP_SHORT;
    end
    PosInd = PosInd + temp_Cp_length;
    data_to_FFT = DataOfdmIn(PosInd + (1: IFFT_SIZE));                        % 去除CP，提取数据部分
    post_FFT=fft(data_to_FFT)/sqrt(IFFT_SIZE);                                % FFT变换
    DataSymMatrix((1:(ReFreNum/2)), TimeInd)=post_FFT((IFFT_SIZE-ReFreNum/2+1) : IFFT_SIZE);  %negative part
    DataSymMatrix(((ReFreNum/2+1):ReFreNum), TimeInd)=post_FFT(2:(ReFreNum/2+1));         %positive part
    PosInd = PosInd + IFFT_SIZE;
end

%% 解资源映射
CsirsSymMatrix = DataSymMatrix.*conj(CSIRS_MAP);
PilotSymInd = 1;
PilotSize = sum(sum(CSIRS_MAP ~= 0));
PilotSymOut = zeros(1,PilotSize);                                           % 输出DMRS向量初始化
for TimeInd=1:ReTimeNum
    for FreInd=1:ReFreNum
        if CSIRS_MAP(FreInd, TimeInd) ~= 0                                 %根据映射矩阵确定CSIRS时频位置
            PilotSymOut(PilotSymInd) = CsirsSymMatrix(FreInd, TimeInd);      %输出的DMRS向量
            PilotSymInd=PilotSymInd+1;
        end
    end
end


