%% �������ܣ�
% ����������ݽ��н�OFDM���ƺͽ���Դӳ��
%% ���������
% DataOfdmIn���������������
% CSIRS_MAP����Դӳ�����
% pdschConfig:
%% �������
% PilotSymOut�����������Դӳ����DMRS
%% Modify history
% 2018/1/17 created by Liu Chunhua
%% code
function [ PilotSymOut] = Deofdm_Modulation_CSIRS(DataOfdmIn,CSIRS_MAP,pdschConfig)
IFFT_SIZE = pdschConfig.IfftSize;
CP_LONG = pdschConfig.SamplesPerLongCP;
CP_SHORT = pdschConfig.SamplesPerShortCP;
LONG_CP_PERIOD = pdschConfig.LongCPPeriod;    %test code!!!
[ReFreNum, ReTimeNum] = size(CSIRS_MAP);
DataSymMatrix = zeros(ReFreNum, ReTimeNum);                                 % ϵͳʱƵ��Դ��
PosInd =0;
%% ��OFDM����
for TimeInd=1:ReTimeNum                                                     % �ж�CP����
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
    data_to_FFT = DataOfdmIn(PosInd + (1: IFFT_SIZE));                        % ȥ��CP����ȡ���ݲ���
    post_FFT=fft(data_to_FFT)/sqrt(IFFT_SIZE);                                % FFT�任
    DataSymMatrix((1:(ReFreNum/2)), TimeInd)=post_FFT((IFFT_SIZE-ReFreNum/2+1) : IFFT_SIZE);  %negative part
    DataSymMatrix(((ReFreNum/2+1):ReFreNum), TimeInd)=post_FFT(2:(ReFreNum/2+1));         %positive part
    PosInd = PosInd + IFFT_SIZE;
end

%% ����Դӳ��
CsirsSymMatrix = DataSymMatrix.*conj(CSIRS_MAP);
PilotSymInd = 1;
PilotSize = sum(sum(CSIRS_MAP ~= 0));
PilotSymOut = zeros(1,PilotSize);                                           % ���DMRS������ʼ��
for TimeInd=1:ReTimeNum
    for FreInd=1:ReFreNum
        if CSIRS_MAP(FreInd, TimeInd) ~= 0                                 %����ӳ�����ȷ��CSIRSʱƵλ��
            PilotSymOut(PilotSymInd) = CsirsSymMatrix(FreInd, TimeInd);      %�����DMRS����
            PilotSymInd=PilotSymInd+1;
        end
    end
end


