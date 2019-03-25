%% Function Description
%  Generate CDL channel
%% Input
%  BlockInd : double
%             Index of slot 
%  channel :  structure
%             configuration information for channel
%  gnb     :  structure
%             configuration information for gNB
%% Output
%   H:        4-dimensional array (UE_ANT_NUM-NB_ANT_NUM-MUL_PATH-(number of samples per slot + Max_Delay)).
%             channel matrix
%% Modify history
% 2018/1/18 created by Liu Chunhua 
% 2018/5/17 modified by Song Erhao
%% code
function [H_average,DELAY_OUT] = GenerateCDLChannel(BlockInd,channel,gnb)
%CDL�ŵ�����
CDL_B.Delay=[0.0000,0.1072,0.2155,0.2095,0.2870,0.2986,0.3752,0.5055,0.3681,0.3697,0.5700,0.5283,1.1021,1.2756,1.5474,1.7842,2.0169,2.8294,3.0219,3.6187,4.1067,4.2790,4.7834];
CDL_B.Power= [1.0000,0.6026,0.3981,0.4786,0.1047,0.7586,0.4571,0.3020,0.1738,0.5012,0.1288,0.1259,0.3311,0.2692,0.1778,0.6457,0.1738,0.0603,0.1047,0.0724,0.0324,0.1202,0.0741];
CDL_B.AOD= [9.3	9.3	9.3	-34.1	-65.4	-11.4	-11.4	-11.4	-67.2	52.5	-72	74.3	-52.2	-50.5	61.4	30.6	-72.5	-90.6	-77.6	-82.6	-103.6	75.6	-77.6];
CDL_B.AOA=[-173.3	-173.3	-173.3	125.5	-88	155.1	155.1	155.1	-89.8	132.1	-83.6	95.3	103.7	-87.8	-92.5	-139.1	-90.6	58.6	-79	65.8	52.7	88.7	-60.4];
CDL_B.ZOD=[105.8	105.8	105.8	115.3	119.3	103.2	103.2	103.2	118.2	102	100.4	98.3	103.4	102.5	101.4	103	100	115.2	100.5	119.6	118.7	117.8	115.7];
CDL_B.ZOA= [78.9	78.9	78.9	63.3	59.9	67.5	67.5	67.5	82.6	66.3	61.6	58	78.2	82	62.4	78	60.9	82.9	60.8	57.3	59.9	60.1	62.3];
CDL_B.ASD=10;
CDL_B.ASA=22;
CDL_B.ZSD=3;
CDL_B.ZSA=7;
CDL_B.XPR=8;
CDL_B.ClusterNum=23;
CDL_B.subpathNum=20;
CDL_B.InitialPhase_VV = 2*pi * rand(length(CDL_B.AOA), CDL_B.subpathNum)-pi;
CDL_B.InitialPhase_VH = 2*pi * rand(length(CDL_B.AOA), CDL_B.subpathNum)-pi;
CDL_B.InitialPhase_HV = 2*pi * rand(length(CDL_B.AOA), CDL_B.subpathNum)-pi;
CDL_B.InitialPhase_HH = 2*pi * rand(length(CDL_B.AOA), CDL_B.subpathNum)-pi;
CDL = CDL_B;

DELAY_SPREAD=channel.DelaySpread;
SUBCARRIER_SPACE=gnb.SubcarrierSpacing;
IFFT_SIZE=channel.IFFTSize;
DELAY_TIME=DELAY_SPREAD*CDL.Delay;                           
Ts=1*10^(-3)/SUBCARRIER_SPACE/IFFT_SIZE;           % ����ʱ����
DELAY_OUT=floor(DELAY_TIME/Ts);                    %�����ӳٵ���
%period = 1* 10^(-3);                              
period=1*10^(-3)/(SUBCARRIER_SPACE/15);            % ����ÿ������ʱ����
CenterFrequency = channel.CenterFrequency;         % ����Ƶ��
speed_of_light=2.99792458e8;                       % ����
wavelength=speed_of_light/CenterFrequency;         % ����
k_CONST=2*pi/wavelength;                          
K = 10.^(CDL.XPR/10);     % ���漫����
N = CDL.ClusterNum;       % �صĸ���
M = CDL.subpathNum;       % �Ӿ���
S = channel.NBAntNum;    % ���Ͷ�������
U = channel.UEAntNum;    % ���ܶ�������
V = channel.UESpeed;    % �ն��ٶȴ�С
V_direction = V*[0,1,0];  % �ն��ٶ�ʸ��

%% Antenna element position
MsElementPosition = [0 1 0;0 1 0];    % ���ն�λ������
BsElementPosition = [0 0 0;0 0 0];    % ���Ͷ�λ������

%% angle offset
path_delta_deg = [0.0447    0.1413    0.2492    0.3715    0.5129    0.6797    0.8844    1.1481    1.5195    2.1551];
path_delta_deg = [path_delta_deg;-path_delta_deg];   % 20���Ӿ��ĽǶ�ƫ��
path_delta_deg = path_delta_deg(:);                  % �������Ϊһ��,��20��M����  
path_delta_deg = repmat(path_delta_deg,1,N);         % �������Ϊ20��M)��N��

%% generate angle
alpha = 45; 
beta = 45;    % ����任�Ƕ�

AOA = repmat(CDL_B.AOA,M,1) + CDL_B.ASA*path_delta_deg;                           %20*23,���������Ӿ����������Ǵ�
AOD = repmat(CDL_B.AOD,M,1) + CDL_B.ASD*path_delta_deg;
ZOA = repmat(CDL_B.ZOA,M,1) + CDL_B.ZSA*path_delta_deg;
ZOD = repmat(CDL_B.ZOD,M,1) + CDL_B.ZSD*path_delta_deg;

NLOS_thita = acosd(cosd(beta)*cosd(ZOD) + sind(beta)*cosd(AOD-alpha));
NLOS_thita = mod(NLOS_thita,180);
NLOS_phi = rad2deg(angle((cosd(beta)*sind(ZOD).*cosd(AOD-alpha)-sind(beta).*cosd(ZOD))+1j*(sind(AOD-alpha).*sind(ZOD))));
PHI = rad2deg(angle(cosd(beta)*sind(ZOD)-sind(beta)*cosd(ZOD).*cosd(AOD-alpha)+1j*sind(beta)*sind(AOD-alpha)));

% antenna gain
NLOS_gain_V = -min(12*((NLOS_thita-90)/65).^2,30);
NLOS_gain_H = -min(12*((NLOS_phi)/65).^2,30);
Total_gain = -min(-(NLOS_gain_V + NLOS_gain_H),30);
Total_gain = 10.^(Total_gain/10);

% antenna element field pattern
F_thita_NLOS_L = sqrt(Total_gain)*cosd(45);
F_phi_NLOS_L = sqrt(Total_gain)*sind(45);

%% channel initialization and generate
t=(BlockInd-1)*period:Ts:(BlockInd*period-Ts+max(DELAY_TIME));    %����ʱ������
P_num = size(t,2);
H_average = zeros(U,S,N,P_num);

   

for u = 1: U
    du = MsElementPosition(u,:);

    for s = 1 : S
        ds = BsElementPosition(s,:);
        
        for iCluster = 1 : N
            temp = zeros(M,P_num); % ��ʼ��
            for isubpath = 1 : M
                rx = [sind(ZOA(isubpath,iCluster))*cosd(AOA(isubpath,iCluster));sind(ZOA(isubpath,iCluster))*sind(AOA(isubpath,iCluster));cosd(ZOA(isubpath,iCluster))];
                tx = [sind(ZOD(isubpath,iCluster))*cosd(AOD(isubpath,iCluster));sind(ZOD(isubpath,iCluster))*sind(AOD(isubpath,iCluster));cosd(ZOD(isubpath,iCluster))];
                Fr = [1;0];
                Ft = [cosd(PHI(isubpath,iCluster)),-sind(PHI(isubpath,iCluster));sind(PHI(isubpath,iCluster)) cosd(PHI(isubpath,iCluster))]*[F_thita_NLOS_L(isubpath,iCluster);F_phi_NLOS_L(isubpath,iCluster)];   %ȫ�־ֲ�����ϵת��
                temp(isubpath,:) = Fr'*[sqrt(K/(1+K))*exp(1j*CDL_B.InitialPhase_VV(iCluster,isubpath)) sqrt(1/(1+K))*exp(1j*CDL_B.InitialPhase_VH(iCluster,isubpath));sqrt(1/(1+K))*exp(1j*CDL_B.InitialPhase_HV(iCluster,isubpath)) sqrt(K/(1+K))*exp(1j*CDL_B.InitialPhase_HH(iCluster,isubpath))]*Ft*exp(1j*k_CONST*rx'*du')*exp(1j*k_CONST*tx'*ds')*exp(1j*k_CONST*rx'*V_direction'*t);
            end
            temp = sqrt(CDL_B.Power(iCluster)/M)*sum(temp,1); %��������ͣ����Ը�isubpath���
            H_average(u,s,iCluster,:) = temp;
        end      
    end
end
end
