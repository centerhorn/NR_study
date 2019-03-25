%% Function Description
%  Generate  channel coefficient
%% Input
%  channel :  structure
%             configuration information for channel
%% Output
%   coefficientH:        4-dimensional array (UE_ANT_NUM-NB_ANT_NUM-ClusterNum-Subpath
%                        channel coefficient
%   coefficientT:        4-dimensional array (UE_ANT_NUM-NB_ANT_NUM-ClusterNum-Subpath
%                        channel coefficient
%% Modify history
% 2018/5/24 created by Song Erhao
function [coefficientH,coefficientT] = nrChannelCoefficentInit(channel)
CenterFrequency =channel.CenterFrequency;
speed_of_light=3.0e8;
wavelength=speed_of_light/CenterFrequency;
k_CONST=2*pi/wavelength;

%% velocity
V = channel.UESpeed;
VDirection = V * [1;0;0];
%%  Antenna configuration
AntennaParameters();

%% select model
if strcmp(channel.Type,'CDL-C')
    CDL_C();
    K = 10.^(CDL.XPR/10);
    load CDL_C_RandomPhase.mat RandomPhase;
    coefficientH = zeros(UEAntennaTotalNumber,BSAntennaTotalNumber,ClusterNum,20);
    coefficientT = coefficientH;
    %% channel coefficient calcluate
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
                for isubpath = 1 : 20
                    A_vertical_dB = -min( 12* ((CDL.ZOD(isubpath,iCluster)/pi*180 - 90)/65).^2, 30);
                    A_horizontal_dB = -min( 12*((CDL.AOD(isubpath,iCluster)/pi*180)/65).^2,30);
                    A_dB = -min(-(A_vertical_dB + A_horizontal_dB),30);
                    A = 10.^((A_dB)/10);
                    F_tx = [sqrt(A)*cos(BS_slant_angle);sqrt(A)*sin(BS_slant_angle)];
                    F_rx = [cos(UE_slant_angle) sin(UE_slant_angle)];
                    rx = [sin(CDL.ZOA(isubpath,iCluster))*cos(CDL.AOA(isubpath,iCluster)),sin(CDL.ZOA(isubpath,iCluster))*sin(CDL.AOA(isubpath,iCluster)),cos(CDL.ZOA(isubpath,iCluster))];
                    tx = [sin(CDL.ZOD(isubpath,iCluster))*cos(CDL.AOD(isubpath,iCluster)),sin(CDL.ZOD(isubpath,iCluster))*sin(CDL.AOD(isubpath,iCluster)),cos(CDL.ZOD(isubpath,iCluster))];
                    coefficientH(u,s,iCluster,isubpath) =sqrt(CDL.power(iCluster)/20)*F_rx*[exp(1j*RandomPhase(iCluster,isubpath,1)),sqrt(1/K)*exp(1j*RandomPhase(iCluster,isubpath,2));...
                        sqrt(1/K)*exp(1j*RandomPhase(iCluster,isubpath,3)),exp(1j*RandomPhase(iCluster,isubpath,4))]*F_tx*exp(1j*k_CONST*rx*du')*exp(1j*k_CONST*tx*ds');
                    coefficientT(u,s,iCluster,isubpath) = 1j*(k_CONST*rx*VDirection);
                end
            end
        end
    end
    
elseif strcmp(channel.Type,'CDL-D')
    CDL_D();
    K = 10.^(CDL.XPR/10);
    LOS = 1;
    load 'CDL_D_RandomPhase.mat' RandomPhase;
    coefficientH = zeros(UEAntennaTotalNumber,BSAntennaTotalNumber,ClusterNum,20);
    coefficientT = coefficientH;
    %% Random phase generate
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
                if LOS == 1 && iCluster == 1
                    
                    A_vertical_dB = -min( 12* ((LOS_ZOD/pi*180 - 90)/65).^2, 30);
                    A_horizontal_dB = -min( 12*((LOS_AOD/pi*180)/65).^2,30);
                    A_dB = -min(-(A_vertical_dB + A_horizontal_dB),30);
                    A = 10.^((A_dB)/10);
                    F_tx = [sqrt(A)*cos(BS_slant_angle);sqrt(A)*sin(BS_slant_angle)];
                    F_rx = [cos(UE_slant_angle) sin(UE_slant_angle)];
                    rx = [sin(LOS_ZOA)*cos(LOS_AOA),sin(LOS_ZOA)*sin(LOS_AOA),cos(LOS_ZOA)];
                    tx = [sin(LOS_ZOD)*cos(LOS_AOD),sin(LOS_ZOD)*sin(LOS_AOD),cos(LOS_ZOD)];
                    coefficientH(u,s,iCluster,1) = sqrt(CDL.power(iCluster))*F_rx*[1 0;0 -1]*F_tx*exp(1j*k_CONST*rx*du')*exp(1j*k_CONST*tx*ds')*exp(-1j*k_CONST*d_3D);
                    coefficientT(u,s,iCluster,1) = 1j*(k_CONST*rx*VDirection);
                else
                    for isubpath = 1 : 20
                        A_vertical_dB = -min( 12* ((CDL.ZOD(isubpath,iCluster-1)/pi*180 - 90)/65).^2, 30);
                        A_horizontal_dB = -min( 12*((CDL.AOD(isubpath,iCluster-1)/pi*180)/65).^2,30);
                        A_dB = -min(-(A_vertical_dB + A_horizontal_dB),30);
                        A = 10.^((A_dB)/10);
                        F_tx = [sqrt(A)*cos(BS_slant_angle);sqrt(A)*sin(BS_slant_angle)];
                        F_rx = [cos(UE_slant_angle) sin(UE_slant_angle)];
                        rx = [sin(CDL.ZOA(isubpath,iCluster-1))*cos(CDL.AOA(isubpath,iCluster-1)),sin(CDL.ZOA(isubpath,iCluster-1))*sin(CDL.AOA(isubpath,iCluster-1)),cos(CDL.ZOA(isubpath,iCluster-1))];
                        tx = [sin(CDL.ZOD(isubpath,iCluster-1))*cos(CDL.AOD(isubpath,iCluster-1)),sin(CDL.ZOD(isubpath,iCluster-1))*sin(CDL.AOD(isubpath,iCluster-1)),cos(CDL.ZOD(isubpath,iCluster-1))];
                        coefficientH(u,s,iCluster,isubpath) = sqrt(CDL.power(iCluster)/20)*F_rx*[exp(1j*RandomPhase(iCluster-1,isubpath,1)),sqrt(1/K)*exp(1j*RandomPhase(iCluster-1,isubpath,2));...
                            sqrt(1/K)*exp(1j*RandomPhase(iCluster-1,isubpath,3)),exp(1j*RandomPhase(iCluster-1,isubpath,4))]*F_tx*exp(1j*k_CONST*rx*du')*exp(1j*k_CONST*tx*ds');
                        coefficientT(u,s,iCluster,isubpath) = 1j*(k_CONST*rx*VDirection);
                    end
                end
            end
        end
    end
end





end