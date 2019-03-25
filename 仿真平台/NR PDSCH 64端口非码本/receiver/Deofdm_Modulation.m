
%% 函数功能：
% 对输入的数据进行解OFDM调制和解资源映射
%% 输入参数：
% DataOfdmIn：待解调的数据流
% RS_MAP_MATRIX：资源映射矩阵
%% 输出参数
% DataSymOut：解调及解资源映射后的数据流
% PilotSymOut：解调及解资源映射后的DMRS
%% Modify history
% 2017/6/5 created by Mao Zhendong
% 2017/10/28 modified by Liu Chunhua
%% code
function [ DataSymOut, PilotSymOut] = Deofdm_Modulation(DataOfdmIn,RS_MAP_MATRIX,DMRS_MAP)

IFFT_SIZE = pdschConfig.IfftSize;
LONG_CP_PERIOD = pdschConfig.LongCPPeriod;
CP_LONG = pdschConfig.SamplesPerLongCP;
CP_SHORT = pdschConfig.SamplesPerShortCP;
[ReFreNum, ReTimeNum] = size(RS_MAP_MATRIX);
DataSymMatrix = zeros(ReFreNum, ReTimeNum);                                 % 系统时频资源块
PosInd =0;
%% 解OFDM调制
for TimeInd=1:ReTimeNum                                                     % 判断CP类型
    if mod(TimeInd,LONG_CP_PERIOD) == 1                                                             
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
DmrsSymMatrix = DataSymMatrix.*conj(DMRS_MAP);
DataSymInd = 1;
DataSize = sum(sum(RS_MAP_MATRIX == 1));                                        
DataSymOut = zeros(1,DataSize);                                             % 输出数据向量初始化                                         
PilotSymInd = 1;
PilotSize = sum(sum(RS_MAP_MATRIX == 2));                                       
PilotSymOut = zeros(1,PilotSize);                                           % 输出DMRS向量初始化
for TimeInd=1:ReTimeNum
    for FreInd=1:ReFreNum
        if RS_MAP_MATRIX(FreInd, TimeInd) == 1                                  % 根据映射矩阵确定数据时频位置
            DataSymOut(DataSymInd) = DataSymMatrix(FreInd, TimeInd);        % 输出的数据向量
            DataSymInd=DataSymInd+1;
        end
        if RS_MAP_MATRIX(FreInd, TimeInd) == 2                                  %根据映射矩阵确定DMRS时频位置
            PilotSymOut(PilotSymInd) = DmrsSymMatrix(FreInd, TimeInd);      %输出的DMRS向量
            PilotSymInd=PilotSymInd+1;
        end        
    end
end

