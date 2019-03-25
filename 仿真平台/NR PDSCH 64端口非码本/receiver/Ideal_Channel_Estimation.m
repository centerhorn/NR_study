%% �������ܣ�
% ���������ŵ����ơ������ŵ����ѵ�����У��پ�����OFDM���ƣ�����Դӳ���Ϊ�����ŵ����ƾ���
%% ���������
% channel_out_train�������ŵ����ѵ������
%% �������
% H_ideal�������ŵ����ƾ���
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

for TimeInd=1:ReTimeNum                                                                   % ȥCP
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
    post_FFT=fft(data_to_FFT);                                                            %ѵ������û����IFFT ����Ҫ��һ��
    DataSymMatrix((1:(ReFreNum/2)), TimeInd)=post_FFT((IFFT_SIZE-ReFreNum/2+1) : IFFT_SIZE);  %negative part
    DataSymMatrix(((ReFreNum/2+1):ReFreNum), TimeInd)=post_FFT(2:(ReFreNum/2+1));         %positive part
    PosInd = PosInd + IFFT_SIZE;
end

DataSymInd = 1;
DataSize = sum(sum(RS_MAP_MATRIX == 1));
H_ideal = zeros(1,DataSize);
for TimeInd=1:ReTimeNum
    for FreInd=1:ReFreNum
        if RS_MAP_MATRIX(FreInd, TimeInd) == 1                                                %����ӳ�����ȷ������ʱƵλ��
            H_ideal(DataSymInd) = DataSymMatrix(FreInd, TimeInd);                         %�����������
            DataSymInd=DataSymInd+1;
        end 
    end
end
