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

%% �������ܣ�
% ����Rhh,Rdh��ؾ��󣬸��ݾ�������չ������Լ��ŵ��ӳٹ����׷ֱ����ʱ��Ƶ����ؾ����ټ����ֵ����
%% �������
% Rhh����Ƶ����ؾ���
% Rdh�������뵼Ƶ�Ļ���ؾ���
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

%% ����ʱ�������
% Slot�ĳ���
period = channel.SlotDuration;
% ��������Ƶƫ��Ƶ��Hz,�ٶ�m/s����λҪ��һ��
fDmax = UE_SPEED*CARRIER_FREQUENCY/3e8;
% ����ÿ�����ŵ�ʱ�䳤�ȣ�����CP
SymbolDuration = period/SYMBOL_PER_SLOT;
DeltaT = (0:(SYMBOL_PER_SLOT-1))*SymbolDuration;
Rtt = besselj(0,2*pi*fDmax*DeltaT);
%% ����Ƶ�������
% �����ӳٹ�����
% �����ӳٹ�����
for n = 1:(MAX_DELAY+1)
    index = find((DELAY_OUT+1)==n);
    PDP(n) = sum(Am(index).^2);
end
Rf = fft(PDP,IFFT_SIZE);
Rff = Rf.';
%% ����ʱƵ���ŵ���ؾ���
RffRtt = Rff*Rtt;
%% �����ֵ����
CSIRSLen = size(CSIRS_LOCATION,2);
DataLen = size(DATA_LOCATION,2);
PortNum = size(CSIRS_LOCATION,3);

Rhh = zeros(CSIRSLen,CSIRSLen,PortNum);
Rdh = zeros(DataLen,CSIRSLen,PortNum);
% ���㵼Ƶ����ؾ���
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
% ���㵼Ƶ�����ݼ�Ļ���ؾ���
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
    



