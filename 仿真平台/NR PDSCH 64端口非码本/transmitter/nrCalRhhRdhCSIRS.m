%% Function Description
%  Calculate Rhh,Rdh Correlation matrix
%% Input
%  CSIRS_LOCATION:   3-Dimensional array (2(FreInd and TimeInd)-(number of CSIRS RE)- port)
%                 location of CSIRS in the grid
%  DATA_LOCATION: 3-Dimensional array (2(FreInd and TimeInd)-(number of Data RE)-rank)
%                 location of Data in the grid
%  channel      : structure
%                 configuration information for channel
%% Output
%  Rhh          : 3-Dimensional array ((number of CSIRS RE)-(number of CSIRS RE)-rank or port)
%                 pilot Autocorrelation matrix
%  Rdh          : 3-Dimensional array ((number of Data RE)-(number of CSIRS RE)-rank or port)
%               : Data and CSIRS Cross-correlation matrix
%% Modify History
% 2018/01/18 created by Liu Chunhua 
% 2018/05/21 modified by Song Erhao

%% 函数功能：
% 计算Rhh,Rdh相关矩阵，根据经典多普勒功率谱以及信道延迟功率谱分别估算时域、频域相关矩阵，再计算插值矩阵
%% 输出参数
% Rhh：导频自相关矩阵
% Rdh：数据与导频的互相关矩阵
%% Modify history
% 2018/1/18 created by Liu Chunhua 
%% code

function [Rhh,Rdh] = nrCalRhhRdhCSIRS(CSIRS_LOCATION,DATA_LOCATION,channel)
UE_SPEED = channel.UESpeed;
CARRIER_FREQUENCY = channel.CenterFrequency;
SYMBOL_PER_SLOT = channel.SymbolsPerSlot;
IFFT_SIZE= channel.IfftSize;
Am = channel.Am;
DELAY_OUT = channel.DelayOut;
MAX_DELAY = channel.MaxDelay;

%% 计算时域相关性
% Slot的长度
period = channel.SlotDuration;
% 最大多普勒频偏，频率Hz,速度m/s，单位要归一化
fDmax = UE_SPEED*CARRIER_FREQUENCY/3e8;
% 计算每个符号的时间长度，包括CP
SymbolDuration = period/SYMBOL_PER_SLOT;
DeltaT = (0:(SYMBOL_PER_SLOT-1))*SymbolDuration;
Rtt = besselj(0,2*pi*fDmax*DeltaT);
%% 计算频域相关性
% 计算延迟功率谱
% 计算延迟功率谱
for n = 1:(MAX_DELAY+1)
    index = find((DELAY_OUT+1)==n);
    PDP(n) = sum(Am(index).^2);
end
Rf = fft(PDP,IFFT_SIZE);
Rff = Rf.';
%% 计算时频域信道相关矩阵
RffRtt = Rff*Rtt;
%% 计算插值矩阵
CSIRSLen = size(CSIRS_LOCATION,2);
DataLen = size(DATA_LOCATION,2);
PortNum = size(CSIRS_LOCATION,3);

Rhh = zeros(CSIRSLen,CSIRSLen,PortNum);
Rdh = zeros(DataLen,CSIRSLen,PortNum);
% 计算导频自相关矩阵
for PortInd = 1:PortNum
    for CSIRSInd1 = 1:CSIRSLen
        for CSIRSInd2 = 1:CSIRSLen
            DeltaF = abs(CSIRS_LOCATION(1,CSIRSInd2,PortInd) - CSIRS_LOCATION(1,CSIRSInd1,PortInd))+1;
            DeltaT = abs(CSIRS_LOCATION(2,CSIRSInd2,PortInd) - CSIRS_LOCATION(2,CSIRSInd1,PortInd))+1;
            if CSIRS_LOCATION(1,CSIRSInd1,PortInd) >= CSIRS_LOCATION(1,CSIRSInd2,PortInd)
                Rhh(CSIRSInd1,CSIRSInd2,PortInd) = RffRtt(DeltaF,DeltaT);
            else
                Rhh(CSIRSInd1,CSIRSInd2,PortInd) = RffRtt(DeltaF,DeltaT)';
            end
        end
    end
end
% 计算导频和数据间的互相关矩阵
for PortInd = 1:PortNum
    for DataInd = 1:DataLen
        for CSIRSInd = 1:CSIRSLen
            DeltaF = abs(DATA_LOCATION(1,DataInd,1) - CSIRS_LOCATION(1,CSIRSInd,PortInd))+1;
            DeltaT = abs(DATA_LOCATION(2,DataInd,1) - CSIRS_LOCATION(2,CSIRSInd,PortInd))+1;
            if DATA_LOCATION(1,DataInd,1) >= CSIRS_LOCATION(1,CSIRSInd,PortInd)
                Rdh(DataInd,CSIRSInd,PortInd) = RffRtt(DeltaF,DeltaT);
            else
                Rdh(DataInd,CSIRSInd,PortInd) = RffRtt(DeltaF,DeltaT)';
            end
        end
    end
end
end
    



