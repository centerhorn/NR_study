%====================����һ֡һ֡����=================%
%====================ÿһ֡��10����֡=================%
clear all;
close all;
clc;
addpath(genpath(pwd));
global_parameters;
config_global_parameters();
Snr = -6;
Rx_CFO = [(2*rand(1, 1)-1)*0.1 (2*rand(1, 1)-1)*5];
%% General parameters
nid_1 = 200;
nid_2 = 0;
BW = 5;         %MHz
CFO_per_ppm = 4; %kHz
N=1; %�²�������
%% �����������
TTIs=3000;      %�������е���������
% ͬ������ʱƵ��ʼλ��
k0_pss = NUM_USED_SUBCARRIER/2-PSS_ALLOCATED_LENGTH/2;
l_pss = 3;
k0_sss = NUM_USED_SUBCARRIER/2-PSS_ALLOCATED_LENGTH/2;
l_sss = l_pss+2;
sss_pss_distance = 2*(CP_LENGTH_SHORT+IFFT_SIZE);
%% Rx parameters
% ���ڵ��ԡ�����ƽ̨
PSS_first_position = SUBFRAME_LEN/2 - (IFFT_SIZE+CP_LENGTH_SHORT)*4 -IFFT_SIZE + 1;

res_fre_offset1 = [];
res_fre_offset2 = [];
res_time_offset1 = [];
res_time_offset2 = [];
% ͬ���ɹ�������ʼ��
right_detect1 = 0;
right_detect2 = 0;

hwait = waitbar(0,'��ȴ�>>>>>>>>'); % waitbar�����ľ������ʾ�������н�����
run_length =TTIs;
step=run_length/100;
for I = 1:TTIs
    %% ������
     if run_length-I<=0
         waitbar(I/run_length,hwait,'�������');
         pause(0.05);
     else
         PerStr=fix(I/step);                % fix����0��£ȡ���������������аٷֱ�
         str=['�������У� ',num2str(PerStr),'%'];   % ��1��BlockNum�������㵽1��100�ڣ�����������н��Ȱٷֱ� 
         waitbar(I/run_length, hwait, str);
         pause(0.05);
     end
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
    SnrLinear = 10^(Snr/10);                                     
    NoiseVec = Awgn_Gen(channel_out, SnrLinear);               
    DataAwgn = channel_out + NoiseVec;  

    CFO_Rx = (2*rand(1, 1)-1)*0.1;                                                       %ppm ��0.1ppm���ȷֲ�
    data_Rx1 = DataAwgn.*exp(j*2*pi*CFO_Rx*CFO_per_ppm*1e3*([0:length(ofdm_out1)-1])*Ts);

    CFO_Rx2 = (2*rand(1, 1)-1)*5;
    data_Rx2 = DataAwgn.*exp(j*2*pi*CFO_Rx2*CFO_per_ppm*1e3*([0:length(ofdm_out1)-1])*Ts);
   %% С������  0.1/0.05ppm 
    [ceil_id2, Pss_location, CFO] = PSS_detect(data_Rx1, IFFT_SIZE, N, SUBFRAME_LEN/2 ,CP_LENGTH_SHORT,1);
%     Ƶƫ����
    CFO_total = (CFO_Rx+CFO_TRP)*CFO_per_ppm*1e3;
    CFO_total2 = (CFO_Rx2+CFO_TRP)*CFO_per_ppm*1e3;
    data_Rx1=data_Rx1.*exp(-1*j*2*pi*CFO*([0:length(ofdm_out1)-1])*Ts);
    rx_sss = data_Rx1(Pss_location+sss_pss_distance:Pss_location+sss_pss_distance+IFFT_SIZE-1);
    [id1,  max_corr] = SSS_detect(rx_sss, nid_2);
    
    %% С������ 0.1/5ppm
    [ceil_id2_2, Pss_location2, CFO2] = PSS_detect(data_Rx2, IFFT_SIZE, N, SUBFRAME_LEN/2 ,CP_LENGTH_SHORT,2);
    data_Rx2=data_Rx2.*exp(-1*j*2*pi*CFO2*([0:length(ofdm_out1)-1])*Ts);
    rx_sss2 = data_Rx2(Pss_location2+sss_pss_distance:Pss_location2+sss_pss_distance+IFFT_SIZE-1);
    [id1_2,  max_corr2] = SSS_detect(rx_sss2, nid_2);
    
    %% ͬ���ɹ������ʣ��Ƶƫʱƫ����ֵ
    if(id1==nid_1 && ceil_id2==nid_2 && abs(Pss_location-PSS_first_position)<=CP_LENGTH_SHORT/2)
        res_fre_offset1 = [res_fre_offset1 abs(CFO-CFO_total)];
        res_time_offset1 = [res_time_offset1 abs(PSS_first_position-Pss_location)];
    end
    
    if(id1_2==nid_1 && ceil_id2_2 ==nid_2 && abs(Pss_location2-PSS_first_position)<=CP_LENGTH_SHORT/2)
        res_fre_offset2 = [res_fre_offset2 abs(CFO2-CFO_total2)];
        res_time_offset2 = [res_time_offset2 abs(PSS_first_position-Pss_location2)];
    end
end
close(hwait);          % �رս�����

figure(1)
[fre_cdf1,sample_fre1] = ecdf(res_fre_offset1);
plot(sample_fre1,fre_cdf1,'--b');
hold on;
[fre_cdf2,sample_fre2] = ecdf(res_fre_offset2);
plot(sample_fre2,fre_cdf2,'-r');
axis([0 15000 0 1]);
title('����ƵƫCDF')
xlabel('����Ƶƫ/Hz')
ylabel('����')
h = legend(['0.05/0.1ppm 3km/h'],['0.05/5ppm 3km/h'],'location','best');
set(h,'Box','off');

figure(2)
y1 = 0;
y2 = 0;
[time_cdf1,sample_time1] = ecdf(res_time_offset1);
[time_cdf2,sample_time2] = ecdf(res_time_offset2);
x1 = 0:0.001:sample_time1(end);
for i=1:length(time_cdf1)
    if i ~= length(time_cdf1)       
        y1=y1+time_cdf1(i)*(x1<sample_time1(i+1)&x1>=sample_time1(i));
    end
end
plot(x1,y1,'-b');
hold on;
x2 = 0:0.001:sample_time2(end);
for i=1:length(time_cdf2)
    if i ~= length(time_cdf2)       
        y2=y2+time_cdf2(i)*(x2<sample_time2(i+1)&x2>=sample_time2(i));
    end
end
plot(x2,y2,'-r');
h = legend(['0.05/0.1ppm 3km/h'],['0.05/5ppm 3km/h'],'location','best');
set(h,'Box','off');
title('����ʱƫCDF')
xlabel('����ʱƫ������������')
ylabel('����')
% plot(sample_time2,time_cdf2,'-*r');
% set(gca,'YTick',min([time_cdf_reshape1 time_cdf_reshape2]):0.05:1);
% title('����ʱƫCDF')
% xlabel('����ʱƫ')
% ylabel('����')
% h = legend(['0.05/0.1ppm 3km/h'],['0.05/5ppm 3km/h'],'location','best');
% set(h,'Box','off');