%% 函数功能：
% 进行理想信道估计。经过信道后的训练序列，再经过解OFDM调制，解资源映射后即为理想信道估计矩阵
%% 输入参数：
% channel_out_train：经过信道后的训练序列
%% 输出参数
% H_ideal：理想信道估计矩阵
%% Modify history
% 2017/6/5 created by Mao Zhendong
% 2017/10/28 modified by Liu Chunhua
%% code
function [ H_ideal ] = Ideal_Channel_Estimation(channel_out_train,pdschConfig,gnbConfig,RS_MAP_MATRIX)
IFFT_SIZE =  pdschConfig.IfftSize;
CP_LONG = pdschConfig.SamplesPerLongCP;
CP_SHORT = pdschConfig.SamplesPerShortCP;

[ReFreNum, ReTimeNum] = size(RS_MAP_MATRIX);
DataSymMatrix = zeros(ReFreNum, ReTimeNum);
PosInd =0;

for TimeInd=1:ReTimeNum                                                                   % 去CP
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
    data_to_FFT = channel_out_train(PosInd + (1: IFFT_SIZE));
    post_FFT=fft(data_to_FFT);                                                            %训练序列没经过IFFT 不需要归一化
    DataSymMatrix((1:(ReFreNum/2)), TimeInd)=post_FFT((IFFT_SIZE-ReFreNum/2+1) : IFFT_SIZE);  %negative part
    DataSymMatrix(((ReFreNum/2+1):ReFreNum), TimeInd)=post_FFT(2:(ReFreNum/2+1));         %positive part
    PosInd = PosInd + IFFT_SIZE;
end

DataSymInd = 1;
DataSize = sum(sum(RS_MAP_MATRIX == 1));
H_ideal = zeros(1,DataSize);
for TimeInd=1:ReTimeNum
    for FreInd=1:ReFreNum
        if RS_MAP_MATRIX(FreInd, TimeInd) == 1                                                %根据映射矩阵确定数据时频位置
            H_ideal(DataSymInd) = DataSymMatrix(FreInd, TimeInd);                         %输出的数据流
            DataSymInd=DataSymInd+1;
        end 
    end
end
