%% Function Description
%  Generate CDL-C-CAICT channel
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
function [H] = GenerateCDL_C_CAICT(BlockInd,channel)
%% wavelength
CenterFrequency =channel.CenterFrequency;
speed_of_light=3.0e8;
wavelength=speed_of_light/CenterFrequency;
k_CONST=2*pi/wavelength;

MAX_DELAY = channel.MaxDelay ;
Ts=1*10^(-3)/channel.T;
period = channel.SlotDuration;
%% velocity
%V = 3/3.6;
V = channel.UESpeed;
VDirection = V * [1;0;0];
%% select model
CDL_C();
load CDL_C_RandomPhase.mat RandomPhase;
% Package number
% %period = 1/(4 * 30720 * 10.^3);                  %period为采样间隔
% period = 1/(10.^3);
% P_num = 5000;
% t = 0 : period : (P_num - 1) * period;

t=BlockInd*period:Ts:((BlockInd+1)*period-Ts+MAX_DELAY*Ts);   %采样时间向量         %实际采样间隔为Ts
P_num = size(t,2);

%% Random phase generate
AntennaParameters();
K = 10.^(CDL.XPR/10);
H = zeros(UEAntennaTotalNumber,BSAntennaTotalNumber,ClusterNum,P_num);
for u = 1 : UEAntennaTotalNumber
    du = UEAntennaLocation(u,:);
    if u <= UEAntennaTotalNumber/2
        UE_slant_angle = UEAntennaPloAngle(1);
    else
        UE_slant_angle = UEAntennaPloAngle(2);
    end
    for s = 1 : BSAntennaTotalNumber
        ds = BSAntennaLocation(s,:);
        if s <= BSAntennaTotalNumber/2
            BS_slant_angle = BSAntennaPloAngle(1);
        else
            BS_slant_angle = BSAntennaPloAngle(2);
        end
        for iCluster =  1 : ClusterNum
            %sprintf('U : %d, S : %d, Cluster : %d',u,s,iCluster)
            tmp = zeros(20,P_num);
            for isubpath = 1 : 20
                A_vertical_dB = -min( 12* ((CDL.ZOD(isubpath,iCluster)/pi*180 - 90)/65).^2, 30);
                A_horizontal_dB = -min( 12*((CDL.AOD(isubpath,iCluster)/pi*180)/65).^2,30);
                A_dB = -min(-(A_vertical_dB + A_horizontal_dB),30);
                A = 10.^((A_dB)/10);
                F_tx = [sqrt(A)*cos(BS_slant_angle);sqrt(A)*sin(BS_slant_angle)];
                F_rx = [cos(UE_slant_angle) sin(UE_slant_angle)];
                rx = [sin(CDL.ZOA(isubpath,iCluster))*cos(CDL.AOA(isubpath,iCluster)),sin(CDL.ZOA(isubpath,iCluster))*sin(CDL.AOA(isubpath,iCluster)),cos(CDL.ZOA(isubpath,iCluster))];
                tx = [sin(CDL.ZOD(isubpath,iCluster))*cos(CDL.AOD(isubpath,iCluster)),sin(CDL.ZOD(isubpath,iCluster))*sin(CDL.AOD(isubpath,iCluster)),cos(CDL.ZOD(isubpath,iCluster))];
                tmp(isubpath,:) =sqrt(CDL.power(iCluster)/20)*F_rx*[exp(1j*RandomPhase(iCluster,isubpath,1)),sqrt(1/K)*exp(1j*RandomPhase(iCluster,isubpath,2));...
                    sqrt(1/K)*exp(1j*RandomPhase(iCluster,isubpath,3)),exp(1j*RandomPhase(iCluster,isubpath,4))]*F_tx*exp(1j*k_CONST*rx*du')*exp(1j*k_CONST*tx*ds')...
                    *exp(1j*(k_CONST*rx*VDirection*t ));
            end
            tmp = sum(tmp);
            H(u,s,iCluster,:) = tmp;
        end
    end
end

end
