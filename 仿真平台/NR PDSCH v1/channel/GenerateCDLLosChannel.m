%% Function Description
%  Generate CDL Los channel
%% Input
%  BlockInd : double
%             Index of slot
%  channel :  structure
%             configuration information for channel
%% Output
%   H:        4-dimensional array (UE_ANT_NUM-NB_ANT_NUM-MUL_PATH-(number of samples per slot + Max_Delay)).
%             channel matrix
%% Modify history
% 2018/5/24 created by Song Erhao

%% code
function [H] = GenerateCDLLosChannel(BlockInd,channel)
%CDL�ŵ�����
RelativePower = channel.RelativePower;
Power=10.^(RelativePower/10)/sum(10.^(RelativePower/10));
InitialPhase_VV = channel.InitialPhase_VV;
InitialPhase_VH = channel.InitialPhase_VH;
InitialPhase_HV = channel.InitialPhase_HV;
InitialPhase_HH = channel.InitialPhase_HH;
MAX_DELAY = channel.MaxDelay ;
Ts=1*10^(-3)/channel.T;
period = channel.SlotDuration;
CenterFrequency = channel.CenterFrequency ;
speed_of_light=2.99792458e8;                       % ����
wavelength=speed_of_light/CenterFrequency;         % ����
k_CONST=2*pi/wavelength;
K = 10.^(channel.XPR_dB/10);     % ���漫����
N = channel.MulPath;       % �صĸ���
M = channel.SubPath;       % �Ӿ���
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
alpha = 0;
beta = 0;
gama = 45;    % ����任�Ƕ�

LOS_ZOD = channel.ZOD_CLUSTER(1);
LOS_AOD = channel.AOD_CLUSTER(1);
LOS_AOA = channel.AOA_CLUSTER(1);
LOS_ZOA = channel.ZOA_CLUSTER(1);
ZOD = repmat(channel.ZOD_CLUSTER(2:1:end),M,1) + channel.C_ZSD*path_delta_deg;
AOD = repmat(channel.AOD_CLUSTER(2:1:end),M,1) + channel.C_ASD*path_delta_deg;
AOA = repmat(channel.AOA_CLUSTER(2:1:end),M,1) + channel.C_ASA*path_delta_deg;
ZOA = repmat(channel.ZOA_CLUSTER(2:1:end),M,1) + channel.C_ZSA*path_delta_deg;

% AOA = repmat(channel.AOA_CLUSTER,M,1) + channel.C_ASA*path_delta_deg;                           %20*23,���������Ӿ����������Ǵ�
% AOD = repmat(channel.AOD_CLUSTER,M,1) + channel.C_ASD*path_delta_deg;
% ZOA = repmat(channel.ZOA_CLUSTER,M,1) + channel.C_ZSA*path_delta_deg;
% ZOD = repmat(channel.ZOD_CLUSTER,M,1) + channel.C_ZSD*path_delta_deg;

NLOS_thita = acosd(cosd(beta)*cosd(gama)*cosd(ZOD) + (sind(beta)*cosd(gama)*cosd(AOD-alpha)-sind(gama)*sind(AOD-alpha).*sind(ZOD)));
NLOS_thita = mod(NLOS_thita,180);
NLOS_phi = rad2deg(angle((cosd(beta)*sind(ZOD).*cosd(AOD-alpha)-sind(beta).*cosd(ZOD))+1j*((cosd(beta)*sind(gama)*cosd(ZOD)+(sind(beta)*sind(gama)*cosd(AOD-alpha)+cosd(gama)*sind(AOD-alpha).*sind(ZOD))))));
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
t=BlockInd*period:Ts:((BlockInd+1)*period-Ts+MAX_DELAY*Ts);   %����ʱ������
P_num = size(t,2);
H = zeros(U,S,N+1,P_num);
d_3D = 50;

for u = 1: U
    du = MsElementPosition(u,:);
    Fr = [1;0];
    for s = 1 : S
        ds = BsElementPosition(s,:);
        
        for iCluster = 1 : N+1
            if iCluster == 1
                rx = [sind(LOS_ZOA)*cosd(LOS_AOA);sind(LOS_ZOA)*sind(LOS_AOA);cosd(LOS_ZOA)];
                temp = sqrt(Power(iCluster))*Fr'*[1 0;0 -1]*Fr*exp(-1j*k_CONST*d_3D)*exp(1j*k_CONST*rx'*du')*exp(1j*(k_CONST*rx'*V_direction'*t ));
            else
                temp = zeros(M,P_num); % ��ʼ��
                for isubpath = 1 : M
                    rx = [sind(ZOA(isubpath,iCluster-1))*cosd(AOA(isubpath,iCluster-1));sind(ZOA(isubpath,iCluster-1))*sind(AOA(isubpath,iCluster-1));cosd(ZOA(isubpath,iCluster-1))];
                    tx = [sind(ZOD(isubpath,iCluster-1))*cosd(AOD(isubpath,iCluster-1));sind(ZOD(isubpath,iCluster-1))*sind(AOD(isubpath,iCluster-1));cosd(ZOD(isubpath,iCluster-1))];
                    Ft = [cosd(PHI(isubpath,iCluster-1)),-sind(PHI(isubpath,iCluster-1));sind(PHI(isubpath,iCluster-1)) cosd(PHI(isubpath,iCluster-1))]*[F_thita_NLOS_L(isubpath,iCluster-1);F_phi_NLOS_L(isubpath,iCluster-1)];   %ȫ�־ֲ�����ϵת��
                    temp(isubpath,:) = Fr'*[sqrt(K/(1+K))*exp(1j*InitialPhase_VV(iCluster-1,isubpath)) sqrt(1/(1+K))*exp(1j*InitialPhase_VH(iCluster-1,isubpath));sqrt(1/(1+K))*exp(1j*InitialPhase_HV(iCluster-1,isubpath)) sqrt(K/(1+K))*exp(1j*InitialPhase_HH(iCluster-1,isubpath))]*Ft*exp(1j*k_CONST*rx'*du')*exp(1j*k_CONST*tx'*ds')*exp(1j*k_CONST*rx'*V_direction'*t);
                end
                temp = sqrt(Power(iCluster)/M)*sum(temp,1); %��������ͣ����Ը�isubpath���
            end
            H(u,s,iCluster,:) = temp;
        end
    end
end
end

