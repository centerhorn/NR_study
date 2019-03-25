
%% �������ܣ�
% ����������ݽ��н�OFDM���ƺͽ���Դӳ��
%% ���������
% DataOfdmIn���������������
% RS_MAP_MATRIX����Դӳ�����
%% �������
% DataSymOut�����������Դӳ����������
% PilotSymOut�����������Դӳ����DMRS
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
DataSymMatrix = zeros(ReFreNum, ReTimeNum);                                 % ϵͳʱƵ��Դ��
PosInd =0;
%% ��OFDM����
for TimeInd=1:ReTimeNum                                                     % �ж�CP����
    if mod(TimeInd,LONG_CP_PERIOD) == 1                                                             
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
DmrsSymMatrix = DataSymMatrix.*conj(DMRS_MAP);
DataSymInd = 1;
DataSize = sum(sum(RS_MAP_MATRIX == 1));                                        
DataSymOut = zeros(1,DataSize);                                             % �������������ʼ��                                         
PilotSymInd = 1;
PilotSize = sum(sum(RS_MAP_MATRIX == 2));                                       
PilotSymOut = zeros(1,PilotSize);                                           % ���DMRS������ʼ��
for TimeInd=1:ReTimeNum
    for FreInd=1:ReFreNum
        if RS_MAP_MATRIX(FreInd, TimeInd) == 1                                  % ����ӳ�����ȷ������ʱƵλ��
            DataSymOut(DataSymInd) = DataSymMatrix(FreInd, TimeInd);        % �������������
            DataSymInd=DataSymInd+1;
        end
        if RS_MAP_MATRIX(FreInd, TimeInd) == 2                                  %����ӳ�����ȷ��DMRSʱƵλ��
            PilotSymOut(PilotSymInd) = DmrsSymMatrix(FreInd, TimeInd);      %�����DMRS����
            PilotSymInd=PilotSymInd+1;
        end        
    end
end

