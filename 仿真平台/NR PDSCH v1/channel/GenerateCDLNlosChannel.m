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
function [H] = GenerateCDLNlosChannel(BlockInd,channel)
%CDL信道参数
RelativePower = channel.RelativePower;
Power=10.^(RelativePower/10)/sum(10.^(RelativePower/10));
InitialPhase_VV = channel.InitialPhase_VV;
InitialPhase_VH = channel.InitialPhase_VH;
InitialPhase_HV = channel.InitialPhase_HV;
InitialPhase_HH = channel.InitialPhase_HH;
% DELAY_OUT = channel.DelayOut;
MAX_DELAY = channel.MaxDelay ;
Ts=1*10^(-3)/channel.T; 
period = channel.SlotDuration;
CenterFrequency = channel.CenterFrequency ;
speed_of_light=2.99792458e8;                       % 光速
wavelength=speed_of_light/CenterFrequency;         % 波长
k_CONST=2*pi/wavelength;
K = 10.^(channel.XPR_dB/10);     % 交叉极化率
N = channel.MulPath;       % 簇的个数
M = channel.SubPath;       % 子径数
S = channel.NBAntNum;    % 发送端天线数
U = channel.UEAntNum;    % 接受端天线数
V = channel.UESpeed;    % 收端速度大小
V_direction = V*[0,1,0];  % 收端速度矢量



%% Antenna element position
MsElementPosition = [0 1 0;0 1 0];    % 接收端位置坐标
BsElementPosition = [0 0 0;0 0 0];    % 发送端位置坐标

%% angle offset
path_delta_deg = [0.0447    0.1413    0.2492    0.3715    0.5129    0.6797    0.8844    1.1481    1.5195    2.1551];
path_delta_deg = [path_delta_deg;-path_delta_deg];   % 20个子径的角度偏移
path_delta_deg = path_delta_deg(:);                  % 将矩阵变为一列,共20（M）行  
path_delta_deg = repmat(path_delta_deg,1,N);         % 将矩阵变为20（M)行N列

%% generate angle
alpha = 0; 
beta = 0;    
gama = 45;    % 坐标变换角度

AOA = repmat(channel.AOA_CLUSTER,M,1) + channel.C_ASA*path_delta_deg;                           %20*23,横坐标是子径，纵坐标是簇
AOD = repmat(channel.AOD_CLUSTER,M,1) + channel.C_ASD*path_delta_deg;
ZOA = repmat(channel.ZOA_CLUSTER,M,1) + channel.C_ZSA*path_delta_deg;
ZOD = repmat(channel.ZOD_CLUSTER,M,1) + channel.C_ZSD*path_delta_deg;

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
t=BlockInd*period:Ts:((BlockInd+1)*period-Ts+MAX_DELAY*Ts);   %采样时间向量
P_num = size(t,2);
H = zeros(U,S,N,P_num);

   

for u = 1: U
    du = MsElementPosition(u,:);

    for s = 1 : S
        ds = BsElementPosition(s,:);
        
        for iCluster = 1 : N
            temp = zeros(M,P_num); % 初始化
            for isubpath = 1 : M
                rx = [sind(ZOA(isubpath,iCluster))*cosd(AOA(isubpath,iCluster));sind(ZOA(isubpath,iCluster))*sind(AOA(isubpath,iCluster));cosd(ZOA(isubpath,iCluster))];
                tx = [sind(ZOD(isubpath,iCluster))*cosd(AOD(isubpath,iCluster));sind(ZOD(isubpath,iCluster))*sind(AOD(isubpath,iCluster));cosd(ZOD(isubpath,iCluster))];
                Fr = [1;0];
                Ft = [cosd(PHI(isubpath,iCluster)),-sind(PHI(isubpath,iCluster));sind(PHI(isubpath,iCluster)) cosd(PHI(isubpath,iCluster))]*[F_thita_NLOS_L(isubpath,iCluster);F_phi_NLOS_L(isubpath,iCluster)];   %全局局部坐标系转化
                temp(isubpath,:) = Fr'*[sqrt(K/(1+K))*exp(1j*InitialPhase_VV(iCluster,isubpath)) sqrt(1/(1+K))*exp(1j*InitialPhase_VH(iCluster,isubpath));sqrt(1/(1+K))*exp(1j*InitialPhase_HV(iCluster,isubpath)) sqrt(K/(1+K))*exp(1j*InitialPhase_HH(iCluster,isubpath))]*Ft*exp(1j*k_CONST*rx'*du')*exp(1j*k_CONST*tx'*ds')*exp(1j*k_CONST*rx'*V_direction'*t);
            end
            temp = sqrt(Power(iCluster)/M)*sum(temp,1); %列向量求和，即对各isubpath求和
            H(u,s,iCluster,:) = temp;
        end      
    end
end
end




