d_3D = 30;
%% CDL_D
CDL.delay = [0,0,0.035,0.612,1.363,1.405,1.804,2.596,1.775,4.042,7.937,9.424,9.708,12.525];
CDL.power = [-0.2,-13.5,-18.8,-21,-22.8,-17.9,-20.1,-21.9,-22.9,-27.8,-23.6,-24.8,-30.0,-27.7];
CDL.power = 10.^(CDL.power/10)/sum(10.^(CDL.power/10));
CDL.AOD = [0,0,89.2,89.2,89.2,13,13,13,34.6,-64.5,-32.9,52.6,-132.1,77.2];
CDL.AOA = [-180,-180,89.2,89.2,89.2,163,163,163,-137,74.5,127.7,-119.6,-9.1,-83.8];
CDL.ZOD = [98.5,98.5,85.5,85.5,85.5,97.5,97.5,97.5,98.5,88.4,91.3,103.8,80.3,86.5];
CDL.ZOA = [81.5,81.5,86.9,86.9,86.9,79.4,79.4,79.4,78.2,73.6,78.3,87,70.6,72.9];
CDL.ASD = 5;
CDL.ASA = 8;
CDL.ZSD = 3;
CDL.ZSA = 3;
CDL.XPR = 11;
%% Cluster Number
ClusterNum = length(CDL.AOD);
%% Offset Angle
DeltaAngle_Arrive = [0.0447    0.1413    0.2492    0.3715    0.5129    0.6797    0.8844    1.1481    1.5195    2.1551];
DeltaAngle_Arrive = [ DeltaAngle_Arrive ; -DeltaAngle_Arrive ];
DeltaAngle_Arrive = DeltaAngle_Arrive(:);
DeltaAngle_Departure = [ DeltaAngle_Arrive(11:20) ; DeltaAngle_Arrive(1:10)];
DeltaAngle_Arrive = repmat(DeltaAngle_Arrive,1,ClusterNum - 1);
DeltaAngle_Departure = repmat(DeltaAngle_Departure,1,ClusterNum - 1);
%% ray angle
LOS_ZOD = CDL.ZOD(1) / 180 * pi;
LOS_AOD = CDL.AOD(1) / 180 * pi;
LOS_AOA = CDL.AOA(1) / 180 * pi;
LOS_ZOA = CDL.ZOA(1) / 180 * pi;
CDL.AOD = repmat(CDL.AOD(2:end),20,1) + CDL.ASD*DeltaAngle_Departure;
CDL.AOD = CDL.AOD / 180 * pi;
CDL.ZOD = repmat(CDL.ZOD(2:end),20,1) + CDL.ZSD*DeltaAngle_Departure;
CDL.ZOD = CDL.ZOD / 180 * pi;
CDL.AOA = repmat(CDL.AOA(2:end),20,1) + CDL.ASA*DeltaAngle_Arrive;
CDL.AOA = CDL.AOA / 180 * pi;
CDL.ZOA = repmat(CDL.ZOA(2:end),20,1) + CDL.ZSA*DeltaAngle_Arrive;
CDL.ZOA = CDL.ZOA / 180 * pi;
%% rotate departure angle
MeanZOD = 0;
MeanAOD = 0;
for iCluster = 1 : ClusterNum-1
    for iRay = 1 : 20
        MeanZOD = MeanZOD + exp(1j*CDL.ZOD(iRay,iCluster))*CDL.power(iCluster+1)/20;
        MeanAOD = MeanAOD + exp(1j*CDL.AOD(iRay,iCluster))*CDL.power(iCluster+1)/20;
    end
end
MeanZOD = MeanZOD + exp(1j*LOS_ZOD)*CDL.power(1);
MeanAOD = MeanAOD + exp(1j*LOS_AOD)*CDL.power(1);
MeanZOD = angle(MeanZOD);
MeanAOD = angle(MeanAOD);
CDL.AOD = CDL.AOD - MeanAOD + 0;
CDL.ZOD = CDL.ZOD - MeanZOD + pi/2;
LOS_AOD = LOS_AOD - MeanAOD + 0;
LOS_ZOD = LOS_ZOD -  MeanZOD + pi/2;
%% rotate departure angle
MeanZOA = 0;
MeanAOA = 0;
for iCluster = 1 : ClusterNum-1
    for iRay = 1 : 20
        MeanZOA = MeanZOA + exp(1j*CDL.ZOA(iRay,iCluster))*CDL.power(iCluster+1)/20;
        MeanAOA = MeanAOA + exp(1j*CDL.AOA(iRay,iCluster))*CDL.power(iCluster+1)/20;
    end
end
MeanZOA = MeanZOA + exp(1j*LOS_ZOA)*CDL.power(1);
MeanAOA = MeanAOA + exp(1j*LOS_AOA)*CDL.power(1);
MeanZOA = angle(MeanZOA);
MeanAOA = mod(angle(MeanAOA),2*pi);

% MeanAOA = MeanAOA + 2*pi;
CDL.AOA = CDL.AOA - MeanAOA + pi;
CDL.ZOA = CDL.ZOA - MeanZOA + pi/2;
LOS_AOA = LOS_AOA - MeanAOA + pi;
LOS_ZOA = LOS_ZOA -  MeanZOA + pi/2;

%CDL.power = [CDL.power(2:end),CDL.power(1)]; % Turn the LOS path power to the end.
%% coherence time
% F_DopplerSpread = zeros(20,ClusterNum - 1);
% for iCluster = 1 : ClusterNum - 1
%     rx = [sin(CDL.ZOA(:,iCluster)).*cos(CDL.AOA(:,iCluster)),sin(CDL.ZOA(:,iCluster)).*sin(CDL.AOA(:,iCluster)),cos(CDL.ZOA(:,iCluster))];
%     F_DopplerSpread(:,iCluster) = rx * VDirection / wavelength;
% end
% rx_LOS = [sin(LOS_ZOA).*cos(LOS_AOA),sin(LOS_ZOA).*sin(LOS_AOA),cos(LOS_ZOA)];
% F_DopplerSpread_LOS = rx_LOS * VDirection / wavelength;
% tmp_F_DS = reshape(F_DopplerSpread,(ClusterNum - 1)*20,1);
% tmp_F_DS = [tmp_F_DS;F_DopplerSpread_LOS];
% tmpPower = repmat(CDL.power(2:end)/20,20,1);
% tmpPower = reshape(tmpPower,(ClusterNum - 1)*20,1);
% tmpPower = [tmpPower;CDL.power(1)];
% F_RMS = std(tmp_F_DS,tmpPower);
% period = 1 / F_RMS;
%period = 2484/30000;