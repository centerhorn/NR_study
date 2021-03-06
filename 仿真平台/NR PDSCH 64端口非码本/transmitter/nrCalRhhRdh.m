%% Function Description
%  Calculate Rhh,Rdh Correlation matrix
%% Input
% DMRS_LOCATION_SET:   cell array(RANK 1-4)
%                     each cell: 3-Dimensional array (2(FreInd and TimeInd)-(number of DMRS RE)-rank)
%                                location of DMRS in the grid
% DATA_LOCATION_SET:   cell array(RANK 1-4)
%                      each cell:3-Dimensional array (2(FreInd and TimeInd)-(number of Data RE)-rank
%                                location of Data in the grid
%  channel      : structure
%                 configuration information for channel
%% Output
% RhhSet        : cell array(RANK 1-4)
%                 each cell: 3-Dimensional array ((number of DMRS RE)-(number of DMRS RE)-rank or port)
%                            pilot Autocorrelation matrix
% RdhSet        : cell array(RANK 1-4)
%                 each cell : 3-Dimensional array ((number of Data RE)-(number of RS RE)-rank or port)
%                             Data and DMRS Cross-correlation matrix
%% Modify History
% 2018/01/18 created by Liu Chunhua
% 2018/05/21 modified by Song Erhao

function [RhhSet,RdhSet] = nrCalRhhRdh(DMRS_LOCATION_SET,DATA_LOCATION_SET,channel)
RANKMax =4;
RhhSet = cell(1,RANKMax);
RdhSet = cell(1,RANKMax);
% UE_SPEED = channel.UESpeed;
% CARRIER_FREQUENCY = channel.CenterFrequency;
SYMBOL_PER_SLOT = channel.SymbolsPerSlot;
IFFT_SIZE= channel.IfftSize;
Am = channel.Am;
DELAY_OUT = channel.DelayOut;
MAX_DELAY = channel.MaxDelay;
%% 计算时域相关性
% Slot的长度
%period=1*10^(-3)/(SUBCARRIER_SPACE/15);
period = channel.SlotDuration;
% 最大多普勒频偏，频率Hz,速度m/s，单位要归一化
fDmax = channel.fDmax;
% 计算每个符号的时间长度，包括CP
SymbolDuration = period/SYMBOL_PER_SLOT;
DeltaT = (0:(SYMBOL_PER_SLOT-1))*SymbolDuration;
Rtt = besselj(0,2*pi*fDmax*DeltaT);
%% 计算频域相关性
%计算延迟功率谱
for n = 1:(MAX_DELAY+1)
    index = find((DELAY_OUT+1)==n);
    PDP(n) = sum(Am(index).^2);
end
Rf = fft(PDP,IFFT_SIZE);
Rff = Rf.';
%% 计算时频域信道相关矩阵
RffRtt = Rff*Rtt;
for i = 1:RANKMax
    DMRS_LOCATION = DMRS_LOCATION_SET{i};
    DATA_LOCATION = DATA_LOCATION_SET{i};
    %% 计算插值矩阵
    DMRSLen = size(DMRS_LOCATION,2);
    DataLen = size(DATA_LOCATION,2);
    RankNum = size(DMRS_LOCATION,3);            %参考信号为DMRS时应为RankNum,参考信号为CSIRS时应为PortNum
    
    Rhh = zeros(DMRSLen,DMRSLen,RankNum);
    Rdh = zeros(DataLen,DMRSLen,RankNum);
    % 计算导频自相关矩阵
    for RankInd = 1:RankNum
        for DMRSInd1 = 1:DMRSLen
            for DMRSInd2 = 1:DMRSLen
                DeltaF = abs(DMRS_LOCATION(1,DMRSInd2,RankInd) - DMRS_LOCATION(1,DMRSInd1,RankInd))+1;
                DeltaT = abs(DMRS_LOCATION(2,DMRSInd2,RankInd) - DMRS_LOCATION(2,DMRSInd1,RankInd))+1;
                if DMRS_LOCATION(1,DMRSInd1,RankInd) >= DMRS_LOCATION(1,DMRSInd2,RankInd)
                    Rhh(DMRSInd1,DMRSInd2,RankInd) = RffRtt(DeltaF,DeltaT);
                else
                    Rhh(DMRSInd1,DMRSInd2,RankInd) = RffRtt(DeltaF,DeltaT)';
                end
            end
        end
    end
    % 计算导频和数据间的互相关矩阵
    for RankInd = 1:RankNum
        for DataInd = 1:DataLen
            for DMRSInd = 1:DMRSLen
                DeltaF = abs(DATA_LOCATION(1,DataInd,RankInd) - DMRS_LOCATION(1,DMRSInd,RankInd))+1;
                DeltaT = abs(DATA_LOCATION(2,DataInd,RankInd) - DMRS_LOCATION(2,DMRSInd,RankInd))+1;
                if DATA_LOCATION(1,DataInd,RankInd) >= DMRS_LOCATION(1,DMRSInd,RankInd)
                    Rdh(DataInd,DMRSInd,RankInd) = RffRtt(DeltaF,DeltaT);
                else
                    Rdh(DataInd,DMRSInd,RankInd) = RffRtt(DeltaF,DeltaT)';
                end
            end
        end
    end
    RhhSet{i} = Rhh;
    RdhSet{i} = Rdh;
end
end




