%====================����һ֡һ֡����=================%
%====================ÿһ֡��10����֡=================%
%====================BLOCK_NUM=10=================%
clear all;
close all;
clc;
addpath(genpath(pwd));
global_parameters;
config_global_parameters();
Snr = [-10,-9,-8,-7,-6,-5,-4,-3,-2];
Rx_CFO = [(2*rand(1, 1)-1)*0.1 (2*rand(1, 1)-1)*5];
%% General parameters
nid_1 = 200;
nid_2 = 0;
BW = 5;         %MHz
CFO_per_ppm = 4; %kHz
%% �����������
TTIs=5000;      %�������е���������
% ͬ������ʱƵ��ʼλ��
k0_pss = NUM_USED_SUBCARRIER/2-PSS_ALLOCATED_LENGTH/2;
l_pss = 3;
k0_sss = NUM_USED_SUBCARRIER/2-PSS_ALLOCATED_LENGTH/2;
l_sss = l_pss+2;
sss_pss_distance = 2*(CP_LENGTH_SHORT+IFFT_SIZE);
%% Rx parameters
N = 1;                    %�²�������
% ���ڵ��ԡ�����ƽ̨
PSS_first_position = SUBFRAME_LEN/2 - (IFFT_SIZE+CP_LENGTH_SHORT)*4 -IFFT_SIZE + 1;

right_detect_normal = [];
right_detect_normal_large_cfo = [];

hwait = waitbar(0,'��ȴ�>>>>>>>>'); % waitbar�����ľ������ʾ�������н�����
snr_array_length = length(Snr);
step=snr_array_length/100;
for SnrInd = 1:length(Snr)
    % ͬ���ɹ�������ʼ��
    right_detect1 = 0;
    right_detect2 = 0;
    
    %% ������
     if snr_array_length-SnrInd<=0
         waitbar(SnrInd/snr_array_length,hwait,'�������');
         pause(0.05);
     else
         PerStr=fix(SnrInd/step);                % fix����0��£ȡ���������������аٷֱ�
         str=['�������У� ',num2str(PerStr),'%'];   % ��1��BlockNum�������㵽1��100�ڣ�����������н��Ȱٷֱ� 
         waitbar(SnrInd/snr_array_length, hwait, str);
         pause(0.05);
     end
for I = 1:TTIs
    %% DL data generate and Mapping
    initialdata = round(rand(1,NUM_BITS_PER_FRAME));                   %initial data for DL(Physical channel, after channel coding and scrambling);
    [modout] = qpsk(initialdata);                                  %modulation
    data = reshape(modout,NUM_USED_SUBCARRIER,NUM_OFDM_PER_FRAME);
    %% PSS/SSS generate
    % add your codes here(PSS/SSS generate): 
    
    PSS1 = PSS(nid_2);% pss����
    SSS1 = SSS(nid_1,nid_2);
    pss_length = length(PSS1);
    sss_length = length(SSS1);
    PSS_tx = [zeros(1,ceil((PSS_ALLOCATED_LENGTH-pss_length)/2)) PSS1 zeros(1,floor((PSS_ALLOCATED_LENGTH-pss_length)/2))];
    SSS_tx = [zeros(1,ceil((SSS_ALLOCATED_LENGTH-sss_length)/2)) SSS1 zeros(1,floor((SSS_ALLOCATED_LENGTH-sss_length)/2))];
    %% PSS/SSS mapping
    for i = 1:2                                                                       %PSS mapping
        data([k0_pss+[1:PSS_ALLOCATED_LENGTH]],l_pss+14*(i-1)) = PSS_tx;            %the frequency resource here is for PSS
        data([k0_sss+[1:SSS_ALLOCATED_LENGTH]],l_sss+14*(i-1)) = SSS_tx;          %the frequency resource here is for SSS0
        data([k0_pss+[1:PSS_ALLOCATED_LENGTH]],NUM_OFDM_PER_FRAME/2+l_pss+14*(i-1)) = PSS_tx;            %the frequency resource here is for PSS
        data([k0_sss+[1:SSS_ALLOCATED_LENGTH]],NUM_OFDM_PER_FRAME/2+l_sss+14*(i-1)) = SSS_tx;          %the frequency resource here is for SSS0 
    end
    %% OFDM modulation
    [ofdm_out1]=ofdm_mod(data,IFFT_SIZE,NUM_OFDM_SLOT,CP_LENGTH_LONG,CP_LENGTH_SHORT);  
    %% add TRP frequency offset ��0.05ppm���ȷֲ�
    CFO_TRP = (2*rand(1, 1)-1)*0.05;                                                  %ppm
    ofdm_out = ofdm_out1.*exp(j*2*pi*CFO_TRP*CFO_per_ppm*1e3*([0:length(ofdm_out1)-1])*Ts); 

% �ŵ�����
    TU_channel_EPA_genetate_hou;
    
    PreInterfere=zeros(1,SUBFRAME_LEN);
    channel_out = [];
    for block_index = 1:BLOCK_NUM
        % ��ȡ�����ŵ��ļ�
        [H, delay_out, mul_path ] = TU_channel_EPA_from_file(block_index);
        % ��TDL-A�ŵ� 
        [channel_out_end,SignalInterfere]=TU_channel_new(ofdm_out(:,SUBFRAME_LEN*(block_index-1)+1:SUBFRAME_LEN*block_index),PreInterfere,H,delay_out,mul_path);
        % ����ǰ�����td_pss_tx
        PreInterfere = SignalInterfere;
        channel_out = [channel_out, channel_out_end];
    end
    % ��ÿ������ȵ㵥���ֱ����һ�²���
    % ��AWGN�ŵ�
    SnrLinear = 10^(Snr(SnrInd)/10);                                     
    NoiseVec = Awgn_Gen(channel_out, SnrLinear);               
    DataAwgn = channel_out + NoiseVec;  

     %pss���Ժ�ӵ�
    CFO_Rx = (2*rand(1, 1)-1)*0.1;                                                       %ppm ��0.1ppm���ȷֲ�
    data_Rx1 = DataAwgn.*exp(j*2*pi*CFO_Rx*CFO_per_ppm*1e3*([0:length(ofdm_out1)-1])*Ts);

    CFO_Rx2 = (2*rand(1, 1)-1)*5;
    data_Rx2 = DataAwgn.*exp(j*2*pi*CFO_Rx2*CFO_per_ppm*1e3*([0:length(ofdm_out1)-1])*Ts);
   %% С������  0.1/0.05ppm 
    [ceil_id2, Pss_location, CFO] = PSS_detect(data_Rx1, IFFT_SIZE, N, SUBFRAME_LEN/2 ,CP_LENGTH_SHORT,1);
%     Ƶƫ����
%     CFO1 = (CFO_Rx+CFO_TRP)*CFO_per_ppm*1e3
%     CFO2 = (CFO_Rx2+CFO_TRP)*CFO_per_ppm*1e3
    data_Rx1=data_Rx1.*exp(-1*j*2*pi*CFO*([0:length(ofdm_out1)-1])*Ts);
    rx_sss = data_Rx1(Pss_location+sss_pss_distance:Pss_location+sss_pss_distance+IFFT_SIZE-1);
    [id1,  max_corr] = SSS_detect(rx_sss, nid_2);
    
    %% С������ 0.1/5ppm
    [ceil_id2_2, Pss_location2, CFO2] = PSS_detect(data_Rx2, IFFT_SIZE, N, SUBFRAME_LEN/2 ,CP_LENGTH_SHORT,2);
    data_Rx2=data_Rx2.*exp(-1*j*2*pi*CFO2*([0:length(ofdm_out1)-1])*Ts);
    rx_sss2 = data_Rx2(Pss_location2+sss_pss_distance:Pss_location2+sss_pss_distance+IFFT_SIZE-1);
    [id1_2,  max_corr2] = SSS_detect(rx_sss2, nid_2);
    
    % �ж��Ƿ���ɹ�
    if(id1==nid_1 && ceil_id2==nid_2 && abs(Pss_location-PSS_first_position)<=CP_LENGTH_SHORT/2)
        right_detect1 = right_detect1 + 1;
    end
    
    if(id1_2==nid_1 && ceil_id2_2 ==nid_2 && abs(Pss_location2-PSS_first_position)<=CP_LENGTH_SHORT/2)
        right_detect2 = right_detect2 + 1;
    end
end

right_detect_normal = [right_detect_normal right_detect1];
right_detect_normal_large_cfo = [right_detect_normal_large_cfo right_detect2];

end
close(hwait);          % �رս�����
right_detect_normal = right_detect_normal./TTIs;
right_detect_normal_large_cfo = right_detect_normal_large_cfo./TTIs;
figure(10)
plot(Snr,right_detect_normal,'--+b')
hold on;
plot(Snr,right_detect_normal_large_cfo,'-*r')
title('���ϼ��ɹ���')
xlabel('����ȣ�dB��')
ylabel('һ�μ��PSS/SSS���ϼ��ɹ���')
% h = legend(['�Ż��㷨'],['��ͳ�㷨'],['�;�������'],'location','best');
% h = legend(['��ͳ�㷨'],'location','best');
h = legend(['0.05/0.1ppm 3km/h'],['0.05/5ppm 3km/h'],'location','best');
set(h,'Box','off');
set(gca,'YTick',0.4:0.1:1);
save('cellsearch','Snr','right_detect_normal','right_detect_normal_large_cfo');